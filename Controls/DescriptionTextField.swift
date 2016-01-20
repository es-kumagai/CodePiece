//
//  DescriptionTextField.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

final class DescriptionTextField: NSTextField {

	func readyForReplyTo(screenName: String) {
		
		if !containsScreenName(screenName) {
			
			self.stringValue = "@\(screenName) "
		}
	}
	
	func clearTwitterText() {
		
		self.stringValue = ""
	}
}

extension DescriptionTextField : TwitterTextType {
	
	var twitterText: String {
		
		return stringValue.trimmed()
	}
}
