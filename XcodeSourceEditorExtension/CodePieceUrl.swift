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
	var language: String
	var code: String
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
		components.query = "code=\(url.code)"

		guard let instance = components.url else {
			
			return nil
		}
		
		self = instance
	}
}
