//
//  TimelineTableItem.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/09.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim
import ESTwitter

protocol TimelineTableItem {

	var currentHashtags: ESTwitter.HashtagSet { get }
	var timelineItemTweetId: String? { get }
	var timelineCellType: TimelineTableCellType.Type { get }
}

extension NSUserInterfaceItemIdentifier {
	
	static var timeLineCell = NSUserInterfaceItemIdentifier("TimelineCell")
}

protocol TimelineTableCellType : Selectable {
	
	static var userInterfaceItemIdentifier: NSUserInterfaceItemIdentifier { get }
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat

	func toTimelineView() -> NSView
	
	static func makeCellWithItem(item:TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView
}

extension TimelineTableCellType {

	func toTimelineView() -> NSView {
	
		return self as! NSView
	}
	
	static func makeCellForTableView(tableView: NSTableView, owner: AnyObject?) -> TimelineTableCellType {

		return tableView.makeView(withIdentifier: userInterfaceItemIdentifier, owner: owner) as! TimelineTableCellType
	}
}

struct TimelineTweetItem : TimelineTableItem {
	
	var status: Status
	var hashtags: HashtagSet
	
	var timelineItemTweetId: String? {
		
		return self.status.idStr
	}

	var currentHashtags: HashtagSet {
		
		return self.hashtags
	}
	
	var timelineCellType: TimelineTableCellType.Type {
		
		return TimelineTableCellView.self
	}
}

extension TimelineTweetItem : Equatable {
	
	static func == (lhs: TimelineTweetItem, rhs: TimelineTweetItem) -> Bool {
		
		return lhs.status.idStr == rhs.status.idStr
	}
}

extension Sequence where Element == Status {
	
	func toTimelineTweetItems(hashtags: HashtagSet) -> [TimelineTweetItem] {
		
		return self.map { TimelineTweetItem(status: $0, hashtags: hashtags) }
	}
}

extension Sequence where Element == TimelineTableItem {
	
	var timelineLatestTweetItem: TimelineTweetItem? {
		
		let validTweetItems = self.flatMap { $0 as? TimelineTweetItem }
		
		return validTweetItems.first
	}
}

extension Sequence where Element : TimelineTableItem {
	
	func timelineItemsAppend<S: Sequence>(items: S) -> [S.Element] where S.Element == TimelineTableItem {
	
		return self.map { $0 as TimelineTableItem } + items
	}
}
