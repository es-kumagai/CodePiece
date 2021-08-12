//
//  ManagedByHashtagsContentsDataSource.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter
import Swim
import Ocean

final class GroupedTweetContentsDataSource: NSObject, TimelineTableDataSource {
	
	private var lastTweetId = Dictionary<HashtagSet, String>()
	
	var items = Array<TimelineTableItem>() {
		
		didSet {
			
			items.timelineLatestTweetItem.executeIfExists(setLatestTweet)
		}
	}
	
}

extension GroupedTweetContentsDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		
		return items.count
	}
	
	func latestTweetIdForHashtags(hashtags: HashtagSet) -> String? {
		
		return lastTweetId[hashtags]
	}
	
	func setLatestTweet(item: TimelineTweetItem) {
		
		lastTweetId[item.currentHashtags] = item.timelineItemTweetId!
	}
	
	@discardableResult
	func appendHashtags(hashtags: HashtagSet) -> ProcessExitStatus {
		
		let latestHashtags = items.first?.currentHashtags
		let needAppending = { () -> Bool in
			
			switch latestHashtags {
				
			case .none:
				return true
				
			case .some(let v):
				return v != hashtags
			}
		}
		
		if needAppending() {
			
			let item = TimelineHashtagTableCellItem(previousHashtags: latestHashtags, currentHashtags: hashtags)
			
			items.insert(item, at: 0)
			
			return .passed
		}
		else {
			
			return .aborted(in: -1)
		}
	}
}
