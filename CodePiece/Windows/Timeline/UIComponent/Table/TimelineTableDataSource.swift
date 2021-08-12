//
//  TimelineDataSource.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2015/08/24.
//  Copyright © 2015年 EasyStyle G.K. All rights reserved.
//

import Cocoa
//import ESTwitter
//import Swim

protocol TimelineTableDataSource : NSTableViewDataSource {

	var items: Array<TimelineTableItem> { get }
}

//@objcMembers
//final class TimelineTableDataSource : NSObject, NSTableViewDataSource {
//
//	var maxTweets = 200
//
//	private var lastTweetId = Dictionary<HashtagSet, String>()
//
//	var items = Array<TimelineTableItem>() {
//
//		didSet {
//
//			items.timelineLatestTweetItem.executeIfExists(setLatestTweet)
//		}
//	}
//
//	func appendTweets(tweets: [ESTwitter.Status], hashtags: ESTwitter.HashtagSet) {
//
//		let newTweets = tweets
//			.orderByNewCreationDate()
//			.toTimelineTweetItems(hashtags: hashtags)
//			.timelineItemsAppend(items: items)
//			.prefix(maxTweets)
//
//		items = Array(newTweets)
//	}
//
//	@discardableResult
//	func appendHashtags(hashtags: HashtagSet) -> ProcessExitStatus {
//
//		let latestHashtags = items.first?.currentHashtags
//		let needAppending = { () -> Bool in
//
//			switch latestHashtags {
//
//			case .none:
//				return true
//
//			case .some(let v):
//				return v != hashtags
//			}
//		}
//
//		if needAppending() {
//
//			let item = TimelineHashtagTableCellItem(previousHashtags: latestHashtags, currentHashtags: hashtags)
//
//			items.insert(item, at: 0)
//
//			return .passed
//		}
//		else {
//
//			return .aborted(in: -1)
//		}
//	}
//
//	func numberOfRows(in tableView: NSTableView) -> Int {
//
//		return items.count
//	}
//
//	func setNeedsEstimateHeight() {
//
//	}
//
//	func estimateCellHeightOfRow(row:Int, tableView:NSTableView) -> CGFloat {
//
//		let item = items[row]
//
//		return item.timelineCellType.estimateCellHeightForItem(item: item, tableView: tableView)
//	}
//}
//
//extension TimelineTableDataSource {
//
//	func latestTweetIdForHashtags(hashtags: HashtagSet) -> String? {
//
//		return lastTweetId[hashtags]
//	}
//
//	func setLatestTweet(item: TimelineTweetItem) {
//
//		lastTweetId[item.currentHashtags] = item.timelineItemTweetId!
//	}
//}
