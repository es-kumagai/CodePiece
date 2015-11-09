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
	
			self.lastTweetID = self.items.timelineItemFirstTweetId
		}
	}
	
	private(set) var lastTweetID:String?

	func appendTweets(tweets: [ESTwitter.Status]) {
		
		let newTweets = tweets.orderByNewCreationDate().timelineItemsAppend(self.items).prefix(self.maxTweets)
		
		self.items = Array(newTweets)
	}
	
	func appendHashtag(hashtag: ESTwitter.Hashtag) -> ProcessingState {
		
		let latestItem = self.items.first as? TimelineHashtagTableCellItem
		
		if latestItem == nil || latestItem!.currentHashtag != hashtag {
			
			let item = TimelineHashtagTableCellItem(previousHashtag: nil, currentHashtag: hashtag)
			
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
