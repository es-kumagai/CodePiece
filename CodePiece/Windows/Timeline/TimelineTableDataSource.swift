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
	
	private var _lastTweetID = Dictionary<ESTwitter.Hashtag, String>()

	func latestTweetIdForHashtag(hashtag: ESTwitter.Hashtag) -> String? {
		
		return self._lastTweetID[hashtag]
	}
	
	func setLatestTweet(item: TimelineTweetItem) {
		
		self._lastTweetID[item.currentHashtag] = item.timelineItemTweetId!
	}
	
	func appendTweets(tweets: [ESTwitter.Status], hashtag: ESTwitter.Hashtag) {
		
		let newTweets = tweets.orderByNewCreationDate().toTimelineTweetItems(hashtag).timelineItemsAppend(self.items).prefix(self.maxTweets)
		
		self.items = Array(newTweets)
	}
	
	func appendHashtag(hashtag: ESTwitter.Hashtag) -> ProcessingState {
		
		let latestHashtag = self.items.first?.currentHashtag
		let needAppending = { () -> Bool in
			
			switch latestHashtag {
				
			case .None:
				return true
				
			case .Some(let v):
				return v != hashtag
			}
		}
		
		if needAppending() {
			
			let item = TimelineHashtagTableCellItem(previousHashtag: latestHashtag, currentHashtag: hashtag)
			
			self.items.insert(item, atIndex: 0)
			
			return .Passed
		}
		else {

			return .Aborted
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
