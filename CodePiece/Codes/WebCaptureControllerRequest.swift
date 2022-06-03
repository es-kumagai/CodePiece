//
//  WebCaptureControllerRequest.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/14
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

@preconcurrency import WebKit
import Swim

extension WebCaptureController {
	
	@objcMembers
	internal class Request : NSObject, @unchecked Sendable {

		typealias CompletionHandler = @Sendable (Result<NSImage, Error>) -> Void
		
		unowned let owner: WebCaptureController

		let captureInfo: CaptureInfo
		let url: String
		let sourceFilename: String
		let completionHandler: CompletionHandler
		
		@MainActor
		let view: WKWebView
		
		init(url: String, sourceFilename: String, owner: WebCaptureController, captureInfo: CaptureInfo, handler: @escaping CompletionHandler) async {
			
			self.owner = owner
			
			self.captureInfo = captureInfo
			self.url = url
			self.sourceFilename = sourceFilename
			self.completionHandler = handler

			self.view = await WKWebView(frame: NSRect(x: 0, y: 0, width: captureInfo.clientFrameWidth, height: captureInfo.clientFrameHeight))
			
			super.init()
			
			await MainActor.run {

				view.navigationDelegate = self
				view.customUserAgent = captureInfo.userAgent
			}
		}
		
		func post() {
			
			let url = URL(string: self.url)!
			let request = URLRequest(url: url)

			Task { @MainActor in
				
				view.load(request)
			}
		}
	}
}

extension WebCaptureController.Request : WKNavigationDelegate {
	
	private func removeFromOwner() {
		
		Task {

			if let index = await owner.requests.firstIndex(of: self) {
				
				await owner.removeRequest(at: index)
			}
		}
	}
	
	private func fulfill(with image: NSImage) {
		
		completionHandler(.success(image))
		removeFromOwner()
	}
	
	private func reject(with error: Error) {
		
		completionHandler(.failure(error))
		removeFromOwner()
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		
		// frame の bounds が更新される前に呼び出される場合があるようなので、
		// 応急対応として待ち時間を挿入します。適切な方法に変える必要があります。（WKWebView ではなく WebView 時代の話）
		Thread.sleep(forTimeInterval: 0.5)
		
		Task { @MainActor [unowned self] () -> Void in
			
			assert(Thread.isMainThread)
			
			var containerNodeId: String {
				
				let targetName = sourceFilename
					.replacingOccurrences(of: ".", with: "-")
					.lowercased()
				
				return "file-\(targetName)"
			}
			
			let specifyNodesScript = """
				const tableNode = document.getElementsByTagName('table')[0];
				const containerNode = document.getElementById('\(containerNodeId)');
				const searchNodes = containerNode.getElementsByTagName('div');
				const headerNode = Array.from(searchNodes).find(node => node.classList.contains('file-header'));
				const contentNode = Array.from(searchNodes).find(node => node.getAttribute('itemprop') == 'text');
				const numNodes = Array.from(contentNode.getElementsByTagName('td')).filter(node => node.classList.contains('blob-num'));
				
				if (headerNode)
				{
					containerNode.removeChild(headerNode);
				}
				
				for (let numNode of numNodes)
				{
					numNode.style.minWidth = '0px';
				}
				
				const freeNode = document.createElement('div');
				
				freeNode.style.width = '\(captureInfo.clientWidth)px';
				freeNode.style.height = '\(captureInfo.clientHeight)px';
				freeNode.appendChild(document.createTextNode(''));
				
				containerNode.insertBefore(freeNode, contentNode.nextSibling);
				
				true;
				"""
			
			let applyingStyleScript = """
				tableNode.style.tabSize = '4';
				containerNode.style.borderRadius = '0px';
				containerNode.style.border = 'thin solid var(--color-bg-canvas)';

				contentNode.style.tabSize = '4';
				contentNode.style.borderRadius = '0px';
				contentNode.style.border = 'thin solid var(--color-bg-canvas)';
				contentNode.style.padding = '6px 0px';
				contentNode.style.overflow = 'auto';
				"""
			
			let gettingBoundsScript = """
				const containerBounds = containerNode.getBoundingClientRect();
				const contentBounds = contentNode.getBoundingClientRect();

				const x = containerBounds.left;
				const y = containerBounds.top;
				const width = containerBounds.width;
				const height = containerBounds.height;
				const contentWidth = contentBounds.width;
				const contentHeight = contentBounds.height;

				const bodyWidth = document.body.offsetWidth;
				const bodyHeight = document.body.offsetHeight;

				[x, y, width, height, bodyWidth, bodyHeight, contentWidth, contentHeight];
				"""
			
			struct BoundsData {
				
				let x: Int
				let y: Int
				let containerWidth: Int
				let containerHeight: Int
				let bodyWidth: Int
				let bodyHeight: Int
				let contentWidth: Int
				let contentHeight: Int
				
				init(bounds: Array<NSNumber>) {
					
					x = bounds[0].intValue
					y = bounds[1].intValue
					containerWidth = bounds[2].intValue
					containerHeight = bounds[3].intValue
					bodyWidth = bounds[4].intValue
					bodyHeight = bounds[5].intValue
					contentWidth = bounds[6].intValue
					contentHeight = bounds[7].intValue
				}
			}
			
			var bounds: BoundsData
			
			do {

				try await webView.evaluate(javaScript: specifyNodesScript)
				try await webView.evaluate(javaScript: applyingStyleScript)

				guard let results = try await webView.evaluate(javaScript: gettingBoundsScript) as? Array<NSNumber> else {
					
					reject(with: .scriptEvaluationError("Unexpected result"))
					return
				}
				
				bounds = BoundsData(bounds: results)
				
				let effectiveHeight = max(min(bounds.contentHeight, captureInfo.extendedHeight), captureInfo.minHeight)
				let effectiveWidth = min(max(bounds.contentHeight * 16 / 9, captureInfo.minWidth), captureInfo.maxWidth)
				
				NSLog("Captured : (\(effectiveWidth), \(effectiveHeight)) { min: (\(captureInfo.minWidth), \(captureInfo.minHeight)), max: (\(captureInfo.maxWidth), \(captureInfo.extendedHeight)), container: (\(bounds.containerWidth), \(bounds.containerHeight)), content: (\(bounds.contentWidth), \(bounds.contentHeight)) }")
				
				view.frame = NSRect(x: 0, y: 0, width: bounds.bodyWidth, height: bounds.bodyHeight)
				
				let configuration = instanceApplyingExpression(with: WKSnapshotConfiguration()) { settings in
					
					settings.rect = NSRect(x: bounds.x, y: bounds.y, width: effectiveWidth, height: effectiveHeight)
				}
					
				guard let image = try? await webView.takeSnapshot(configuration: configuration) else {
					
					reject(with: .failedToTakeSnapshot)
					return
				}

				fulfill(with: image)
			}
			catch let error as WKWebView.InternalError {
				
				switch error {
				
				case .unexpected(let message):
					reject(with: .scriptEvaluationError("Unexpected error: \(message)"))
				}
			}
			catch let error as NSError {

				let message: String
				
				if error.domain == "WKErrorDomain", let description = error.userInfo["WKJavaScriptExceptionMessage"] as? String {

					message = description
				}
				else {

					message = error.localizedDescription
				}

				reject(with: .scriptEvaluationError(message))
			}
		}
	}
	
	nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Swift.Error) {

		reject(with: .webLoadingError(error))
	}
}
