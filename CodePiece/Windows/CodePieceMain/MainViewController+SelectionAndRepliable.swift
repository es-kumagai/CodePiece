//
//  MainViewController+Repliable.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

extension MainViewController /*ViewControllerSelectable*/ {
	
	var canReplyToSelectedStatuses: Bool {
		
		return NSApp.currentSelectedStatuses.count == 1
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
	
		Task { @MainActor in
			
			guard canReplyToSelectedStatuses else {
				
				clearReplyingStatus()
				return
			}
			
			setReplyToBySelectedStatuses()

			if let status = statusForReplyTo, await !twitterController.isMyTweet(status: status) {

				descriptionTextField.readyForReplyTo(screenName: status.user.screenName)
			}

			focusToDescription()
			updateControlsDisplayText()
		}
	}
}
