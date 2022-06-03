//
//  WebView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/01.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
	
	enum InternalError : Error {
	
		case unexpected(String)
	}

	@discardableResult
	func evaluate(javaScript string: String) async throws -> Any {

		try await withCheckedThrowingContinuation { continuation in
			
			evaluateJavaScript(string) { value, error in

				switch (value, error) {
					
				case let (value?, nil):
					continuation.resume(returning: value)

				case let (nil, error?):
					continuation.resume(throwing: error)

				case let (value?, error?):
					continuation.resume(throwing: InternalError.unexpected("Both value and error were found.\nValue: \(value), Error: \(error)"))

				case (nil, nil):
					continuation.resume(throwing: InternalError.unexpected("Both value and error couldn't be get."))
				}
			}
		}
	}
}
