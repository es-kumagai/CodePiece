//
//  MyTweetsContentsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter
import Swim
import Ocean

final class ManagedByTweetContentsDataSource: NSObject, TimelineTableDataSource {
	
	var lastTweetId: String? = nil
	
	var items = Array<TimelineTableItem>() {
		
		didSet (previousItems) {
			
			if let item = items.timelineLatestTweetItem {
				
				lastTweetId = item.timelineItemTweetId
			}
		}
	}
}

extension ManagedByTweetContentsDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		
		return items.count
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
