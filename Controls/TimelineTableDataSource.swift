//
//  TimelineDataSource.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2015/08/24.
//  Copyright © 2015年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import APIKit

final class TimelineTableDataSource : NSObject, NSTableViewDataSource {
	
	var hashtag:Twitter.Hashtag = "" {
		
		didSet {
			
			if self.hashtag != oldValue {
				
				self.updateStatuses()
			}
		}
	}
	
	var lastTweetID:String?
	
	func updateStatuses() {
		
		sns.twitter.getStatusesWithQuery(self.hashtag.description, since: self.lastTweetID) { result in
			
			switch result {
				
			case .Success(let tweets):
				break
				
			case .Failure(let error):
				break
				
			}
		}
	}
	
	func clearStatuses() {
		
	}
}
