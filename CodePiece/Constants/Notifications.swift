//
//  Notifications.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Ocean
import Accounts
import ESTwitter

// MARK: - Settings Notification

extension Authorization {

	final class GitHubAuthorizationStateDidChangeNotification : NotificationProtocol {
		
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

extension MainViewController {

	final class PostCompletelyNotification : NotificationProtocol {
		
		var container: PostDataContainer
		
		init(container: PostDataContainer) {
			
			self.container = container
		}
	}
	
	final class PostFailedNotification : NotificationProtocol {
		
		var container: PostDataContainer
		
		init(container: PostDataContainer) {
			
			self.container = container
		}
	}
}

extension TwitterAccountSelectorController {
	
//	final class TwitterAccountSelectorDidChangeNotification : NotificationProtocol {
//		
//		private(set) var account: TwitterController.Account
//		
//		init(account: TwitterController.Account) {
//			
//			self.account = account
//		}
//	}
}

final class HashtagsDidChangeNotification : NotificationProtocol {
	
	private(set) var hashtags:ESTwitter.HashtagSet
	
	init(hashtags:ESTwitter.HashtagSet) {
		
		self.hashtags = hashtags
	}
}
