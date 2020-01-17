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

private var thread = DispatchQueue(label: "jp.ez-style.CodePiece.CodeCaptureController")

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
	
	@objc internal class Request : NSObject {
		
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
			
			self.view.navigationDelegate = self
			self.view.customUserAgent = captureInfo.userAgent
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

//			// TODO: 汎用性を確保するためには DOM を渡して切り取る範囲を返す機能を切り出す必要があります。
//			let dom = frame.domDocument!
//			let content = self.captureInfo.targetNode(sender, dom)
//
//			// TODO: content が取得できず nil になる場合もあるので対応が必要
//			if let contentBound = content?.boundingBox() {
//
//				let image = frame.frameView.documentView!.capture(contentBound)
//
//				self.fulfillRequest(image)
//			}
//			else {
//
//				self.fulfillRequest(for: nil)
//			}
			
			let configuration = instanceApplyingExpression(with: WKSnapshotConfiguration()) { settings in
				
			}
			
			webView.takeSnapshot(with: configuration) { image, error in

				guard let image = image else {
					
					self.fulfillRequest(for: nil)
					return
				}
				
				self.fulfillRequest(for: image)
			}
		}
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
				
		DispatchQueue.main.async {
			
			self.fulfillRequest(for: nil)
		}
	}
}
