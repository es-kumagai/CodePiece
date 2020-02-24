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
		
		var query: String {
		
			var results = [String]()
			
			if let language = url.language {
				
				results.append("language=\(language)")
			}
			
			if let code = url.code {
				
				results.append("code=\(code)")
			}
			
			return results.joined(separator: "&")
		}

		components.query = query

		guard let instance = components.url else {
			
			return nil
		}
		
		self = instance
	}
}
