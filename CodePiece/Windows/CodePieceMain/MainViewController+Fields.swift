//
//  MainViewController+Fields.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

enum ReplyStyle {

	case NormalPost
	case ReplyPost
	case ChainPost
}

// FIXME: プロトコルにする必要があるのか再検討。当初は MainViewController が肥大化するのをプロトコルで避けたのかもしれないが、今に思うと用途が違う印象。
@MainActor
protocol FieldsController {

	var codeScrollView: NSScrollView! { get }
	var codeTextView: CodeTextView! { get }

	var descriptionTextField: DescriptionTextField! { get }
	var hashTagTextField: HashtagTextField! { get }
	var languagePopUpButton: NSPopUpButton! { get }
	var languageWatermark: WatermarkLabel! { get }
	var hashtagWatermark: WatermarkLabel! { get }
	var postButton: NSButton! { get }
	
	var descriptionCountLabel: NSTextField! { get }
	
	
	func updateControlsDisplayText()
	func updateTweetTextCount()
	func updatePostButtonTitle()

	func updateLanguageWatermark()
	func updateHashtagWatermark()
	
	func clearReplyingStatus()
	func clearCodeText()
	func clearDescriptionText()
	func clearHashtags()
}

extension FieldsController {
	
	func updateWatermark() {
		
		updateLanguageWatermark()
		updateHashtagWatermark()
	}
}

extension MainViewController : FieldsController {
	
	func updateLanguageWatermark() {
		
		languageWatermark.stringValue = selectedLanguage.description
		updateHashtagWatermark()
	}
	
	func updateHashtagWatermark() {
		
		let hashtags = customHashtagsExcludeLanguageHashtag + [selectedLanguage.hashtag]

		hashtagWatermark.stringValue = hashtags.twitterDisplayText
	}

	func updatePostButtonTitle() {
		
		Task { @MainActor in
			
			postButton.title = await getPostButtonTitle()
		}
	}
}

extension FieldsController {

	func clearContents() {
		
		clearCodeText()
		clearDescriptionText()
		clearReplyingStatus()
		
		updateControlsDisplayText()
	}

	func focusToDefaultControl() {
		
		focusToCodeArea()
	}
	
	func focusToCodeArea() {
		
		codeScrollView.becomeFirstResponder()
	}
	
	func focusToDescription() {
		
		descriptionTextField.becomeFirstResponder()
	}
	
	func focusToHashtag() {
		
		hashTagTextField.becomeFirstResponder()
	}
	
	func focusToLanguage() {
		
		// MARK: 😒 I don't know how to show NSPopUpButton's submenu manually. The corresponding menu item is disabled too.
	}
}

extension FieldsController where Self : PostDataManageable {
	
	func updateTweetTextCount() {
		
		descriptionCountLabel.stringValue = String(descriptionCountForPost)
		descriptionCountLabel.textColor = .neutralColor
	}	
}

// extension FieldsController where Self : ViewControllerSelectionAndRepliable {
extension MainViewController {
	
	func getPostButtonTitle() async -> String {
		
		switch await replyStyle {
			
		case .NormalPost:
			return codeTextView.hasCode ? "Post Gist" : "Tweet"

		case .ReplyPost:
			return "Reply"

		case .ChainPost:
			return "Chain Post"
		}
	}
	
	var replyStyle: ReplyStyle {
		
		get async {

			guard let status = statusForReplyTo else {
			
				return .NormalPost
			}
			
			if await NSApp.twitterController.isMyTweet(status: status) {
				
				return .ChainPost
			}
			else {
				
				return descriptionTextField.containsScreenName(screenName: status.user.screenName) ? .ReplyPost : .NormalPost
			}
		}
	}
	
	var isReplying: Bool {
		
		get async {

			switch await replyStyle {
				
			case .NormalPost:
				return false
				
			case .ReplyPost:
				return true
				
			case .ChainPost:
				return true
			}
		}
	}
}

extension FieldsController where Self : KeyValueChangeable {
	
	func updateControlsDisplayText() {
		
		updateTweetTextCount()
		updatePostButtonTitle()
		updateWatermark()
	}
	
	func clearCodeText() {
		
		withChangeValue(for: "canPost") {
			
			codeTextView.clearCodeText()
		}
	}
	
	func clearDescriptionText() {
		
		withChangeValue(for: "canPost") {
			
			descriptionTextField.clearTwitterText()
		}
	}
	
	func clearHashtags() {
		
		withChangeValue(for: "canPost") {
			
			hashTagTextField.hashtags = []
			updateHashtagWatermark()
		}
	}
}
