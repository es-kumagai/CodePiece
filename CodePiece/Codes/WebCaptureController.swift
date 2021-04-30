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
	
	func capture(url: String, of sourceFilename: String, captureInfo: CaptureInfo, completion: @escaping CaptureCompletionHandler) {
	
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

		var captureInfo: CaptureInfo
		var url: String
		var sourceFilename: String
		var completionHandler: WebCaptureController.CaptureCompletionHandler
		
		var view: WKWebView
		
		init(url: String, sourceFilename: String, owner: WebCaptureController, captureInfo: CaptureInfo, handler: @escaping WebCaptureController.CaptureCompletionHandler) {
			
			self.owner = owner
			
			self.captureInfo = captureInfo
			self.url = url
			self.sourceFilename = sourceFilename
			self.completionHandler = handler
			
			view = WKWebView(frame: NSRect(x: 0, y: 0, width: captureInfo.clientFrameWidth, height: captureInfo.clientFrameHeight))
			
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
			
			func finishEvaluating(with error: Error) {
				
				switch error {
				
				case let error as WKWebView.InternalError:
					
					switch error {
					
					case .unexpected(let message):
						NSLog("Script evaluation error: unexpected error: \(message)")
					}
					
				case let error as NSError:

					if error.domain == "WKErrorDomain", let message = error.userInfo["WKJavaScriptExceptionMessage"] as? String {
						
						NSLog("Script evaluation error: \(message)")
					}
					else {
						
						NSLog("Script evaluation error: \(error)")
					}
				}
				
				fulfillRequest(for: nil)
			}

			webView.evaluate(javaScript: specifyNodesScript) { result in
				
				if case let .failure(error) = result {
					
					return finishEvaluating(with: error)
				}
				
				webView.evaluate(javaScript: applyingStyleScript) { result in
										
					if case let .failure(error) = result {
						
						return finishEvaluating(with: error)
					}
					
					webView.evaluate(javaScript: gettingBoundsScript) { result in
						
						do {
							
							let object = try result.get()
							
							guard let results = object as? Array<NSNumber> else {
								
								return fulfillRequest(for: nil)
							}
							
							let x = results[0].intValue
							let y = results[1].intValue
							let containerWidth = results[2].intValue
							let containerHeight = results[3].intValue
							let bodyWidth = results[4].intValue
							let bodyHeight = results[5].intValue
							let contentWidth = results[6].intValue
							let contentHeight = results[7].intValue
							
							let effectiveHeight = max(min(contentHeight, captureInfo.extendedHeight), captureInfo.minHeight)
							let effectiveWidth = min(max(contentHeight * 16 / 9, captureInfo.minWidth), captureInfo.maxWidth)
							
							NSLog("Captured : (\(effectiveWidth), \(effectiveHeight)) { min: (\(captureInfo.minWidth), \(captureInfo.minHeight)), max: (\(captureInfo.maxWidth), \(captureInfo.extendedHeight)), container: (\(containerWidth), \(containerHeight)), content: (\(contentWidth), \(contentHeight)) }")
							
							let rect = NSRect(x: x, y: y, width: effectiveWidth, height: effectiveHeight)
							
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
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
				
		DispatchQueue.main.async { [unowned self] in
			
			fulfillRequest(for: nil)
		}
	}
}
