//
//  MainViewController+Repliable.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

//protocol ViewControllerSelectable : class {
//
//	var selectedStatuses: Array<ESTwitter.Status> { get }
//}

//protocol ViewControllerRepliable : class {
//	
//	var statusForReplyTo: ESTwitter.Status? { get }
//	
//	var canReplyTo: Bool { get }
//}

//protocol ViewControllerSelectionAndRepliable : ViewControllerSelectable, ViewControllerRepliable {
//
//	func setReplyToBySelectedStatuses()
//}
//
//protocol LatestTweetReplyable : LatestTweetManageable {
//
//	func setReplyToByLatestTweet()
//}

extension MainViewController /*ViewControllerSelectable*/ {
	
	var canReplyToSelectedStatuses: Bool {
		
		return NSApp.timelineTabViewController.currentSelectedStatuses.count == 1
	}
}

extension MainViewController /*ViewControllerRepliable*/ {
	
	var hasStatusForReplyTo: Bool {
		
		return statusForReplyTo != nil
	}
}

extension MainViewController /*LatestTweetReplyable*/ {
	
	var canReplyToLatestTweet: Bool {
		
		return hasLatestTweet
	}
}

extension MainViewController {

	var canReplyTo: Bool {
	
		return canReplyToSelectedStatuses
	}
	
	var canMakeThread: Bool {
	
		return canReplyToLatestTweet
	}
	
	@IBAction func setMakeThread(_ sender: Any) {
	
		guard canMakeThread else {

			clearReplyingStatus()
			return
		}
		
		setReplyToByLatestTweet()
	}
	
	@IBAction func setReplyTo(_ sender: Any) {
		
		guard canReplyTo else {
			
			clearReplyingStatus()
			return
		}
		
		setReplyToBySelectedStatuses()

		if let status = statusForReplyTo, !twitterController.isMyTweet(status: status) {

			descriptionTextField.readyForReplyTo(screenName: status.user.screenName)
		}

		focusToDescription()
		updateControlsDisplayText()
	}
}


extension MenuController {
	
	var canReplyTo: Bool {
		
		return mainViewController?.canReplyTo ?? false
	}
	
	@IBAction func replyTo(_ sender: NSMenuItem) {
		
		mainViewController?.setReplyTo(sender)
	}
	
	var canMakeThread: Bool {
		
		return mainViewController?.canMakeThread ?? false
	}
	
	@IBAction func makeThread(_ sender: NSMenuItem) {
		
		mainViewController?.setMakeThread(sender)
	}
}
