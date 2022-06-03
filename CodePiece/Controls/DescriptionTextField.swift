//
//  DescriptionTextField.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

@MainActor
@objcMembers
final class DescriptionTextField: NSTextField {

	func readyForReplyTo(screenName: String) {
		
		if !containsScreenName(screenName: screenName) {
			
			stringValue = "@\(screenName) "
		}
	}
	
	func clearTwitterText() {
		
		stringValue = ""
	}
}

extension DescriptionTextField : TwitterTextType {
	
	var twitterText: String {
		
		stringValue.trimmingCharacters(in: .whitespaces)
	}
}
