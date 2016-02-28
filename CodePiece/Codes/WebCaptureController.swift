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
import Swift
import ESThread

private var thread = Thread(name: "jp.ez-style.CodePiece.CodeCaptureController")

final class WebCaptureController {
	
	typealias CaptureCompletionHandler = (NSImage?) -> Void
	
	private var requests:[Request]
	
	init() {

		self.requests = [Request]()
	}
	
	func capture<CaptureInfo:CaptureInfoType>(url:String, clientSize size:CGSize? = nil, captureInfo: CaptureInfo, completion:CaptureCompletionHandler) {
	
		post(Request(url: url, owner: self, clientSize: size, captureInfo: captureInfo, handler: completion))
	}
	
	private func post(request:Request) {
		
		thread.invokeAsync {
		
			self.requests.append(request)
			request.post()
		}
	}
}

extension WebCaptureController {
	
	@objc internal class Request : NSObject {
		
		weak var owner:WebCaptureController!

		var captureInfo: CaptureInfoType
		var url:String
		var completionHandler:WebCaptureController.CaptureCompletionHandler
		
		var view:WebView
		
		init<CaptureInfo:CaptureInfoType>(url:String, owner: WebCaptureController, clientSize size: CGSize? = nil, captureInfo: CaptureInfo, handler:WebCaptureController.CaptureCompletionHandler) {
			
			self.owner = owner
			
			self.captureInfo = captureInfo
			self.url = url
			self.completionHandler = handler
			
			let makeView:() -> WebView = {

				if let size = size {
					
					return WebView(frame: NSRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
				}
				else {
					
					return WebView()
				}
			}
			
			self.view = makeView()
			
			super.init()
			
			self.view.frameLoadDelegate = self
			self.view.customUserAgent = captureInfo.userAgent
		}
		
		func post() {
			
			invokeAsyncOnMainQueue {
				
				self.view.mainFrameURL = self.url
			}
		}
	}
}

extension WebCaptureController.Request : WebFrameLoadDelegate {
	
	private func fulfillRequest(image:NSImage?) {
		
		self.completionHandler(image)
		
		thread.invokeAsync {

			if let index = self.owner.requests.indexOf(self) {
			
				self.owner.requests.removeAtIndex(index)
			}
		}
	}
	
	func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
		
		// frame の bounds が更新される前に呼び出される場合があるようなので、
		// 応急対応として待ち時間を挿入します。適切な方法に変える必要があります。
		sleepForSecond(0.5)
		
		invokeAsyncOnMainQueue { [unowned self] in

			// TODO: 汎用性を確保するためには DOM を渡して切り取る範囲を返す機能を切り出す必要があります。
			let dom = frame.DOMDocument
			let content = self.captureInfo.targetNode(sender, dom)
			
			// TODO: content が取得できず nil になる場合もあるので対応が必要
			let contentBound = content.boundingBox()
			let image = frame.frameView.documentView.capture(contentBound)
			
			self.fulfillRequest(image)
		}
	}
	
	func webView(sender: WebView!, didFailLoadWithError error: NSError!, forFrame frame: WebFrame!) {
		
		invokeAsyncOnMainQueue {
			
			self.fulfillRequest(nil)
		}
	}
}
