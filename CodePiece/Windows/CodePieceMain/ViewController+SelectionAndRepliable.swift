//
//  ViewController+Repliable.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

protocol ViewControllerSelectable : class {
	
	var selectedStatuses: Array<ESTwitter.Status> { get }
}

protocol ViewControllerRepliable : class {
	
	var statusForReplyTo: ESTwitter.Status? { get }
}

protocol ViewControllerSelectionAndRepliable : ViewControllerSelectable, ViewControllerRepliable {
	
	func clearReplyTo()
	func setReplyToBySelectedStatuses()
}

protocol LatestTweetReplyable : LatestTweetManageable {
	
	var replyToType: ReplyToType { get }

	func clearLatestTweet()
	func setReplyToByLatestTweet()
}

enum ReplyToType {
	
	case LatestTweet
	case SelectedStatus
}

extension ViewControllerSelectable {
	
	var canReplyToSelectedStatuses: Bool {
		
		return selectedStatuses.count == 1
	}
}

extension ViewControllerRepliable {
	
	var hasStatusForReplyTo: Bool {
		
		return statusForReplyTo.isExists
	}
}

extension LatestTweetReplyable {
	
	var canReplyToLatestTweet: Bool {
		
		return hasLatestTweet
	}
}

extension ViewControllerRepliable where Self : FieldsController {

}

extension ViewControllerSelectionAndRepliable {
	
}

extension ViewController {

	@IBAction func setReplyTo(sender: AnyObject) {
		
		guard canReplyToSelectedStatuses else {
			
			clearReplyTo()
			return
		}

		setReplyToBySelectedStatuses()

		if let status = self.statusForReplyTo where !twitterController.isMyTweet(status) {

			descriptionTextField.readyForReplyTo(status.user.screenName)
		}

		focusToDescription()
		updateControlsDisplayText()
	}
}


extension MenuController {
	
	var canReplyTo: Bool {
		
		return mainViewController?.canReplyToSelectedStatuses ?? false
	}
	
	@IBAction func replyTo(sender:NSMenuItem) {
		
		mainViewController?.setReplyTo(sender)
	}
}
