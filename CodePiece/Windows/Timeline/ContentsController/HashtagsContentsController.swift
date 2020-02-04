//
//  HashtagsContentsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter
import Ocean

class HashtagsContentsController : TimelineContentsController, NotificationObservable {
	
	var hashtags: HashtagSet = NSApp.settings.appState.hashtags ?? [] {
		
		didSet (previousHashtags) {
			
			guard hashtags != previousHashtags else { return }
			
			NSLog("Hashtag did change: \(hashtags)")

			delegate?.timelineContentsChanged?(self)
		}
	}
	
	override func activate() {
		
		super.activate()
		
		observe(notification: HashtagsDidChangeNotification.self) { [unowned self] notification in
			
			self.hashtags = notification.hashtags
		}
	}
}
