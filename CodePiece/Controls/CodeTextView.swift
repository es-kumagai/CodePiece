//
//  CodeTextView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
final class CodeTextView: NSTextView {

}

extension CodeTextView : CodeTextType {
	
	var codeText: String? {
		
		let code = self.string.trimmingCharacters(in: .whitespaces)
		
		guard !code.isEmpty else {
			
			return nil
		}
		
		return code
	}
	
	func clearCodeText() {
		
		self.string = ""
	}
}
