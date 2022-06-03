//
//  WebCaptureController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/26.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

@preconcurrency import Cocoa
import WebKit
import Ocean
import Swim

// FIXME: キャプチャーの Concurrency 対応が難関なので、ひとまずコールバックのままにしておく。
actor WebCaptureController : NSObject {
	
	private(set) var requests: [Request]
	
	override init() {
		
		requests = [Request]()
		
		super.init()
	}
	
	func removeRequest(at index: Int) {
		
		requests.remove(at: index)
	}
	
	func capture(url: String, of sourceFilename: String, captureInfo: CaptureInfo) async throws -> NSImage {
		
		try await withCheckedThrowingContinuation { continuation in
			
			Task {

				let request = await Request(url: url, sourceFilename: sourceFilename, owner: self, captureInfo: captureInfo) { result in
					
					switch result {
						
					case .success(let image):
						continuation.resume(returning: image)
						
					case .failure(let error):
						continuation.resume(throwing: CaptureError.responseError(error))
					}
				}
				
				post(request)
			}
		}
	}
}

private extension WebCaptureController {

//	func request(_ request: Request) async -> NSImage? {
//		
//		
//	}
	
	func post(_ request: Request) {
		
		requests.append(request)
		request.post()
	}
}

extension WebCaptureController {
	
	enum CaptureError : Error {
		
		case responseError(Request.Error)
	}
}
