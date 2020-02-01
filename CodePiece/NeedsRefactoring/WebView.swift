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
	
	typealias EvalueateResult = Result<Any, Error>
	
	enum InternalError : Error {
		
		case unexpected(String)
	}
	
	func evaluate(javaScript string: String, completionHandler handler: ((EvalueateResult) -> Void)? = nil) {

		evaluateJavaScript(string) { value, error in

			guard let handler = handler else {
				
				return
			}
			
			switch (value, error) {
				
			case let (value?, nil):
				handler(.success(value))

			case let (nil, error?):
				handler(.failure(error))

			case let (value?, error?):
				handler(.failure(InternalError.unexpected("Both value and error were found.\nValue: \(value), Error: \(error)")))

			case (nil, nil):
				handler(.failure(InternalError.unexpected("Both value and error couldn't be get.")))
			}
		}
	}
}
