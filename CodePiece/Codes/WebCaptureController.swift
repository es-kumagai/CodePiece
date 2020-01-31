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

		self.requests = [Request]()
	}
	
	func capture<CaptureInfo:CaptureInfoType>(url: String, clientSize size: CGSize? = nil, captureInfo: CaptureInfo, completion: @escaping CaptureCompletionHandler) {
	
		post(Request(url: url, owner: self, clientSize: size, captureInfo: captureInfo, handler: completion))
	}
	
	private func post(_ request: Request) {
		
		thread.async {
		
			self.requests.append(request)
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
		var completionHandler: WebCaptureController.CaptureCompletionHandler
		
		var view: WKWebView
		
		init<CaptureInfo:CaptureInfoType>(url: String, owner: WebCaptureController, clientSize size: CGSize? = nil, captureInfo: CaptureInfo, handler: @escaping WebCaptureController.CaptureCompletionHandler) {
			
			self.owner = owner
			
			self.captureInfo = captureInfo
			self.url = url
			self.completionHandler = handler
			
			let makeView:() -> WKWebView = {

				if let size = size {
					
					return WKWebView(frame: NSRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
				}
				else {
					
					return WKWebView()
				}
			}
			
			self.view = makeView()
			
			super.init()
			
			view.navigationDelegate = self
			view.customUserAgent = captureInfo.userAgent
		}
		
		func post() {
			
			DispatchQueue.main.async {
				
				let url = URL(string: self.url)!
				let request = URLRequest(url: url)
				
				self.view.load(request)
			}
		}
	}
}

extension WebCaptureController.Request : WKNavigationDelegate {
	
	private func fulfillRequest(for image: NSImage?) {
		
		self.completionHandler(image)
		
		thread.async {

			if let index = self.owner.requests.firstIndex(of: self) {
			
				self.owner.requests.remove(at: index)
			}
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		
		// frame の bounds が更新される前に呼び出される場合があるようなので、
		// 応急対応として待ち時間を挿入します。適切な方法に変える必要があります。（WKWebView ではなく WebView 時代の話）
		Thread.sleep(forTimeInterval: 0.5)
		
		DispatchQueue.main.async { [unowned self] in

			let applyingStyleScript = """
				const tableNode = document.getElementsByTagName('table')[0];
				tableNode.style.tabSize = '4';
				const containerNode = document.getElementById('file-codepiece-swift');
				const searchNodes = containerNode.getElementsByTagName('div');

				for (let i = 0; i != searchNodes.length; ++i) {
					const node = searchNodes[i];
					if (node.getAttribute('itemprop') == 'text') {
						node.style.tabSize = '4';
						node.style.border = 'thin solid #f7f7f7';
						node.style.padding = '6px';
						node.style.width = '\(self.captureInfo.clientSize.width)px';
						node.style.maxHeight = '\(self.captureInfo.clientSize.height)px';
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
			
			webView.evaluateJavaScript("\(applyingStyleScript)\n\(gettingBoundsScript)") { object, error in

				guard let object = object as? Array<Int> else {
					
					return self.fulfillRequest(for: nil)
				}
				
				let x = object[0]
				let y = object[1]
				let width = object[2]
				let height = object[3]
				let bodyWidth = object[4]
				let bodyHeight = object[5]
				
				let rect = NSRect(x: x, y: y, width: width, height: height)
				
				self.view.frame = NSRect(x: 0, y: 0, width: bodyWidth, height: bodyHeight)
				
				print(rect)
				
				let configuration = instanceApplyingExpression(with: WKSnapshotConfiguration()) { settings in
					
					settings.rect = rect
				}
				
				webView.takeSnapshot(with: configuration) { image, error in
					
					guard let image = image else {
						
						self.fulfillRequest(for: nil)
						return
					}
					
					self.fulfillRequest(for: image)
				}
			}
//			// TODO: 汎用性を確保するためには DOM を渡して切り取る範囲を返す機能を切り出す必要があります。
//			let content = frame!.domDocument!.getElementsByClassName("blob-file-content")!.item(0)
//			let contentBound = node?.boundingBox()
			
//			let content = self.captureInfo.targetNode(sender, dom)
//
//			// TODO: content が取得できず nil になる場合もあるので対応が必要
//			if let contentBound = content?.boundingBox() {
//
////				let image = frame.frameView.documentView!.capture(contentBound)
//
//			}
//			else {
//
//				self.fulfillRequest(for: nil)
//			}
			
		}
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
				
		DispatchQueue.main.async {
			
			self.fulfillRequest(for: nil)
		}
	}
}
