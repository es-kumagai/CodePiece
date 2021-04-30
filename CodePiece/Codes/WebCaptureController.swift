//
//  WebCaptureController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/26.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import WebKit
import Ocean
import Swim

private var thread = DispatchQueue(label: "jp.ez-net.CodePiece.CodeCaptureController")

final class WebCaptureController {
	
	typealias CaptureCompletionHandler = (NSImage?) -> Void
	
	private var requests: [Request]
	
	init() {

		requests = [Request]()
	}
	
	func capture<CaptureInfo:CaptureInfoType>(url: String, of sourceFilename: String, captureInfo: CaptureInfo, completion: @escaping CaptureCompletionHandler) {
	
		post(Request(url: url, sourceFilename: sourceFilename, owner: self, captureInfo: captureInfo, handler: completion))
	}
	
	private func post(_ request: Request) {
		
		thread.async { [unowned self] in
		
			requests.append(request)
			request.post()
		}
	}
}

extension WebCaptureController {
	
	@objcMembers
	internal class Request : NSObject {
		
		weak var owner: WebCaptureController!

		var captureInfo: CaptureInfoType
		var url: String
		var sourceFilename: String
		var completionHandler: WebCaptureController.CaptureCompletionHandler
		
		var view: WKWebView
		
		init<CaptureInfo:CaptureInfoType>(url: String, sourceFilename: String, owner: WebCaptureController, captureInfo: CaptureInfo, handler: @escaping WebCaptureController.CaptureCompletionHandler) {
			
			self.owner = owner
			
			self.captureInfo = captureInfo
			self.url = url
			self.sourceFilename = sourceFilename
			self.completionHandler = handler
			
			view = WKWebView(frame: NSRect(origin: .zero, size: captureInfo.frameSize))
			
			super.init()
			
			view.navigationDelegate = self
			view.customUserAgent = captureInfo.userAgent
		}
		
		func post() {
			
			DispatchQueue.main.async { [unowned self] in
				
				let url = URL(string: self.url)!
				let request = URLRequest(url: url)
				
				view.load(request)
			}
		}
	}
}

extension WebCaptureController.Request : WKNavigationDelegate {
	
	private func fulfillRequest(for image: NSImage?) {
		
		completionHandler(image)
		
		thread.async { [unowned self] in

			if let index = owner.requests.firstIndex(of: self) {
			
				owner.requests.remove(at: index)
			}
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		
		// frame の bounds が更新される前に呼び出される場合があるようなので、
		// 応急対応として待ち時間を挿入します。適切な方法に変える必要があります。（WKWebView ではなく WebView 時代の話）
		Thread.sleep(forTimeInterval: 0.5)
		
		DispatchQueue.main.async { [unowned self] in

			var containerNodeId: String {
				
				let targetName = sourceFilename
					.replacingOccurrences(of: ".", with: "-")
					.lowercased()
				
				return "file-\(targetName)"
			}
			
			let applyingStyleScript = """
				const tableNode = document.getElementsByTagName('table')[0];
				const containerNode = document.getElementById('\(containerNodeId)');
				const searchNodes = containerNode.getElementsByTagName('div');

				tableNode.style.tabSize = '4';
				containerNode.style.borderRadius = '0px';

				for (let i = 0; i != searchNodes.length; ++i) {
					const node = searchNodes[i];
					if (node.getAttribute('itemprop') == 'text') {
						node.style.tabSize = '4';
						node.style.borderRadius = '0px';
						node.style.border = 'thin solid var(--color-bg-canvas)';
						node.style.padding = '6px';
						node.style.width = '\(captureInfo.clientSize.width)px';
						node.style.minHeight = '\(captureInfo.clientSize.height)px';
						node.style.maxHeight = '\(captureInfo.maxHeight)px';
						node.style.overflow = 'auto';
						break;
					}
				}
				"""
			
			let gettingBoundsScript = """
				const targetNode = document.getElementsByClassName('data')[0];
				const bounds = targetNode.getBoundingClientRect();

				const x = bounds.left;
				const y = bounds.top;
				const width = bounds.width;
				const height = bounds.height;

				const bodyWidth = document.body.offsetWidth;
				const bodyHeight = document.body.offsetHeight;

				[x, y, width, height, bodyWidth, bodyHeight];
				"""
			
			webView.evaluate(javaScript: applyingStyleScript) { result in
				
				func finishEvaluating(with error: Error) {
					
					NSLog("Script evaluation error: \(error)")
					fulfillRequest(for: nil)
				}
				
				if case let .failure(error) = result {

					finishEvaluating(with: error)
				}
				
				webView.evaluate(javaScript: gettingBoundsScript) { result in
					
					do {
						
						let object = try result.get()
						
						guard let results = object as? Array<Int> else {
							
							return fulfillRequest(for: nil)
						}
						
						let x = results[0]
						let y = results[1]
						let width = results[2]
						let height = results[3]
						let bodyWidth = results[4]
						let bodyHeight = results[5]
						
						let maxWidth = max(height * 2, captureInfo.maxWidth)
						
						let rect = NSRect(x: x, y: y, width: min(width, maxWidth), height: height)
						
						view.frame = NSRect(x: 0, y: 0, width: bodyWidth, height: bodyHeight)
						
						print(rect)
						
						let configuration = instanceApplyingExpression(with: WKSnapshotConfiguration()) { settings in
							
							settings.rect = rect
						}
						
						webView.takeSnapshot(with: configuration) { image, error in
							
							guard let image = image else {
								
								fulfillRequest(for: nil)
								return
							}
							
							fulfillRequest(for: image)
						}
					}
					catch {
						
						finishEvaluating(with: error)
					}
				}
			}
		}
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
				
		DispatchQueue.main.async { [unowned self] in
			
			fulfillRequest(for: nil)
		}
	}
}
