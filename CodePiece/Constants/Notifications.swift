//
//  Notifications.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Ocean
import ESNotification
import Accounts
import ESTwitter

// MARK: - Settings Notification

extension Authorization {

	final class GitHubAuthorizationStateDidChangeNotification : Notification {
		
		private(set) var isValid:Bool
		private(set) var username:String?
		
		init(isValid:Bool, username:String?) {
			
			self.isValid = isValid
			self.username = username
		}
	}

	final class TwitterAuthorizationStateDidChangeNotification : Notification {
		
		private(set) var isValid:Bool
		private(set) var username:String?
		
		init(isValid:Bool, username:String?) {
			
			self.isValid = isValid
			self.username = username
		}		
	}
}

extension ViewController {

	final class PostCompletelyNotification : Notification {
		
		var info: SNSController.PostResultInfo
		
		init(info: SNSController.PostResultInfo) {
			
			self.info = info
		}
	}
	
	final class PostFailedNotification : Notification {
		
		var info: SNSController.PostErrorInfo
		
		init(info: SNSController.PostErrorInfo) {
			
			self.info = info
		}
	}
}

extension TwitterAccountSelectorController {
	
	final class TwitterAccountSelectorDidChangeNotification : Notification {
		
		private(set) var account:TwitterAccount
		
		init(account:TwitterAccount) {
			
			self.account = account
		}
	}
}

final class HashtagsDidChangeNotification : Notification {
	
	private(set) var hashtags:ESTwitter.HashtagSet
	
	init(hashtags:ESTwitter.HashtagSet) {
		
		self.hashtags = hashtags
	}
}
