//
//  Notifications.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Ocean
//import Accounts
import ESTwitter

// MARK: - Settings Notification

extension Authorization {

	final class GistAuthorizationStateDidChangeNotification : NotificationProtocol {
		
		private(set) var isValid:Bool
		private(set) var username:String?
		
		init(isValid:Bool, username:String?) {
			
			self.isValid = isValid
			self.username = username
		}
	}

//	final class TwitterAuthorizationStateDidChangeNotification : NotificationProtocol {
//		
//		private(set) var isValid:Bool
//		private(set) var username:String?
//		
//		init(isValid:Bool, username:String?) {
//			
//			self.isValid = isValid
//			self.username = username
//		}		
//	}
}

final class PostCompletelyNotification : NotificationProtocol {
	
	var container: PostDataContainer
	var postedStatus: Status?
	var hashtags: HashtagSet
	
	init(container: PostDataContainer, postedStatus status: Status?, hashtags: HashtagSet) {
		
		self.container = container
		self.postedStatus = status
		self.hashtags = hashtags
	}
}

final class PostFailedNotification : NotificationProtocol {
	
	var error: SNSController.PostError
	
	init(error: SNSController.PostError) {
		
		self.error = error
	}
}

final class HashtagsDidChangeNotification : NotificationProtocol {
	
	private(set) var hashtags: HashtagSet
	
	init(hashtags: HashtagSet) {
		
		self.hashtags = hashtags
	}
}

final class TimelineSelectionChangedNotification : NotificationProtocol {
	
	private(set) unowned var timelineViewController: TimelineViewController
	private(set) var selectedCells: [TimelineTableView.CellInfo]
	
	init(timelineViewController: TimelineViewController, selectedCells: [TimelineTableView.CellInfo]) {
		
		self.timelineViewController = timelineViewController
		self.selectedCells = selectedCells
	}
}

final class TimelineReplyToSelectionRequestNotification : NotificationProtocol {
	
}

final class MentionUpdatedNotification : NotificationProtocol {
	
	var mentions: [Status]
	var hasNewMention: Bool
	
	init(mentions: [Status], includesNewMention: Bool) {
		
		self.mentions = mentions
		self.hasNewMention = includesNewMention
	}
}
