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

final class HashtagsDidChangeNotification : NotificationProtocol {
	
	private(set) var hashtags: HashtagSet
	
	init(hashtags: HashtagSet) {
		
		self.hashtags = hashtags
	}
}
