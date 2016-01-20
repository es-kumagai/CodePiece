//
//  CodeTextView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

final class CodeTextView: NSTextView {

}

extension CodeTextView : CodeTextType {
	
	var codeText: String? {
		
		guard let code = self.string?.trimmed() where code.isExists else {
			
			return nil
		}
		
		return code
	}
	
	func clearCodeText() {
		
		self.string = ""
	}
}