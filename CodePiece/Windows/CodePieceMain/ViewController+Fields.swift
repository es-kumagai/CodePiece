//
//  ViewController+Fields.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

protocol FieldsController {

	var codeScrollView:NSScrollView! { get }
	var codeTextView:CodeTextView! { get }

	var descriptionTextField:DescriptionTextField! { get }
	var hashTagTextField:HashtagTextField! { get }
	var languagePopUpButton:NSPopUpButton! { get }
	var postButton:NSButton! { get }
	
	var descriptionCountLabel:NSTextField! { get }
	
	
	func updateControlsDisplayText()
	func updateTweetTextCount()
	func updatePostButtonTitle()
	
	func getPostButtonTitle() -> String
	
	func clearReplyTo()
	func clearCodeText()
	func clearDescriptionText()
	func clearHashtags()
}

extension ViewController : FieldsController {
	
}

extension FieldsController {

	func clearContents() {
		
		clearCodeText()
		clearDescriptionText()
		clearReplyTo()
		
		updateControlsDisplayText()
	}

	func focusToDefaultControl() {
		
		self.focusToCodeArea()
	}
	
	func focusToCodeArea() {
		
		self.codeScrollView.becomeFirstResponder()
	}
	
	func focusToDescription() {
		
		self.descriptionTextField.becomeFirstResponder()
	}
	
	func focusToHashtag() {
		
		self.hashTagTextField.becomeFirstResponder()
	}
	
	func focusToLanguage() {
		
		// MARK: 😒 I don't know how to show NSPopUpButton's submenu manually. The corresponding menu item is disabled too.
	}
}

extension FieldsController where Self : PostDataManageable {
	
	func updateTweetTextCount() {
		
		let includesGistsLink = codeTextView.hasCode
		let totalCount = makePostDataContainer().descriptionLengthForTwitter(includesGistsLink: includesGistsLink)
		
		self.descriptionCountLabel.stringValue = String(totalCount)
		self.descriptionCountLabel.textColor = SystemColor.NeutralColor.color
	}	
}

extension FieldsController where Self : ViewControllerSelectionAndRepliable {
	
	func getPostButtonTitle() -> String {
		
		if hasStatusForReplyTo {
			
			return "Reply"
		}
		else {
			
			return codeTextView.hasCode ? "Post Gist" : "Tweet"
		}
	}
}

extension FieldsController where Self : ViewControllerSelectionAndRepliable, Self : KeyValueChangeable {
	
}

extension FieldsController where Self : KeyValueChangeable {
	
	func updateControlsDisplayText() {
		
		updateTweetTextCount()
		updatePostButtonTitle()
	}
	
	func updatePostButtonTitle() {
		
		self.postButton.title = getPostButtonTitle()
	}
	
	func clearCodeText() {
		
		withChangeValue("canPost") {
			
			codeTextView.clearCodeText()
		}
	}
	
	func clearDescriptionText() {
		
		withChangeValue("canPost") {
			
			descriptionTextField.clearTwitterText()
		}
	}
	
	func clearHashtags() {
		
		withChangeValue("canPost") {
			
			self.hashTagTextField.hashtags = []
		}
	}
}
