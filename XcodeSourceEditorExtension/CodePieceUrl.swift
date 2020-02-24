//
//  CodePieceUrl.swift
//  XcodeSourceEditorExtension
//
//  Created by Tomohiro Kumagai on 2020/02/21.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

struct CodePieceUrlScheme {
	
	var method: String
	var language: String? = nil
	var code: String? = nil
}

extension URL {
	
	init?(_ url: CodePieceUrlScheme) {
		
		var components = URLComponents()
		
		#if DEBUG
		components.scheme = "codepiece-beta"
		#else
		components.scheme = "codepiece"
		#endif

		components.host = "open"
		
		var queryItems: [URLQueryItem] {
		
			var items = [URLQueryItem]()
			
			if let language = url.language {
				
				items.append(.init(name: "language", value: language))
			}
			
			if let code = url.code {
				
				items.append(.init(name: "code", value: code))
			}
			
			return items
		}

		components.queryItems = queryItems

		guard let instance = components.url else {
			
			return nil
		}
		
		self = instance
	}
}
