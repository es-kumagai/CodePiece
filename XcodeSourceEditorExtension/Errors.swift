//
//  Errors.swift
//  XcodeSourceEditorExtension
//
//  Created by Tomohiro Kumagai on 2020/02/21.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

enum CodePieceExtensionError {
	
	case failedToOpenCodePiece(String)
}

extension NSError {

	convenience init(_ error: CodePieceExtensionError) {
		
		let domain = "CodePieceErrorDomain"
		let code: Int
		let description: String

		switch error {
			
		case .failedToOpenCodePiece(let message):
			code = 1
			description = message
		}
		
		self.init(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey : description])
	}
}
