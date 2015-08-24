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

extension TwitterAccountSelectorController {
	
	final class TwitterAccountSelectorDidChangeNotification : Notification {
		
		private(set) var account:TwitterAccount
		
		init(account:TwitterAccount) {
			
			self.account = account
		}
	}
}

final class HashtagDidChangeNotification : Notification {
	
	private(set) var hashtag:Twitter.Hashtag
	
	init(hashtag:Twitter.Hashtag) {
		
		self.hashtag = hashtag
	}
}
