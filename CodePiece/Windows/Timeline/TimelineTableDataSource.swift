//
//  TimelineDataSource.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2015/08/24.
//  Copyright © 2015年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import APIKit
import ESTwitter
import Swim

final class TimelineTableDataSource : NSObject, NSTableViewDataSource {
	
	var maxTweets = 200
	
	var items = Array<TimelineTableItem>() {
		
		didSet {
	
			self.items.timelineLatestTweetItem.invokeIfExists(self.setLatestTweet)
		}
	}
	
	private var _lastTweetID = Dictionary<ESTwitter.HashtagSet, String>()

	func latestTweetIdForHashtags(hashtags: ESTwitter.HashtagSet) -> String? {
		
		return self._lastTweetID[hashtags]
	}
	
	func setLatestTweet(item: TimelineTweetItem) {
		
		self._lastTweetID[item.currentHashtags] = item.timelineItemTweetId!
	}
	
	func appendTweets(tweets: [ESTwitter.Status], hashtags: ESTwitter.HashtagSet) {
		
		let newTweets = tweets.orderByNewCreationDate().toTimelineTweetItems(hashtags).timelineItemsAppend(self.items).prefix(self.maxTweets)
		
		self.items = Array(newTweets)
	}
	
	func appendHashtags(hashtags: ESTwitter.HashtagSet) -> ProcessingState {
		
		let latestHashtags = self.items.first?.currentHashtags
		let needAppending = { () -> Bool in
			
			switch latestHashtags {
				
			case .None:
				return true
				
			case .Some(let v):
				return v != hashtags
			}
		}
		
		if needAppending() {
			
			let item = TimelineHashtagTableCellItem(previousHashtags: latestHashtags, currentHashtags: hashtags)
			
			self.items.insert(item, atIndex: 0)
			
			return .Passed
		}
		else {

			return .aborted
		}
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		
		return self.items.count
	}

	func setNeedsEstimateHeight() {
	
	}
	
	func estimateCellHeightOfRow(row:Int, tableView:NSTableView) -> CGFloat {
		
		let item = self.items[row]
		
		return item.timelineCellType.estimateCellHeightForItem(item, tableView: tableView)
	}
}
