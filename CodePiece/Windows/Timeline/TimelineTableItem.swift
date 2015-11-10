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

	var currentHashtag: ESTwitter.Hashtag { get }
	var timelineItemTweetId: String? { get }
	var timelineCellType: TimelineTableCellType.Type { get }
}

protocol TimelineTableCellType : AnyObject, Selectable {
	
	static var prototypeCellIdentifier: String { get }
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat

	func toTimelineView() -> NSView
	
	static func makeCellWithItem(item:TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView
}

extension TimelineTableCellType {

	func toTimelineView() -> NSView {
	
		return self as! NSView
	}
	
	static func makeCellForTableView(tableView: NSTableView, owner: AnyObject?) -> TimelineTableCellType {

		return tableView.makeViewWithIdentifier(self.prototypeCellIdentifier, owner: owner) as! TimelineTableCellType
	}
}

struct TimelineTweetItem : TimelineTableItem {
	
	var status: ESTwitter.Status
	var hashtag: ESTwitter.Hashtag
	
	var timelineItemTweetId: String? {
		
		return self.status.idStr
	}

	var currentHashtag: ESTwitter.Hashtag {
		
		return self.hashtag
	}
	
	var timelineCellType: TimelineTableCellType.Type {
		
		return TimelineTableCellView.self
	}
}

extension SequenceType where Generator.Element == ESTwitter.Status {
	
	func toTimelineTweetItems(hashtag: ESTwitter.Hashtag) -> [TimelineTweetItem] {
		
		return self.map { TimelineTweetItem(status: $0, hashtag: hashtag) }
	}
}

extension SequenceType where Generator.Element == TimelineTableItem {
	
	var timelineLatestTweetItem: TimelineTweetItem? {
		
		let validTweetItems = self.flatMap { $0 as? TimelineTweetItem }
		
		return validTweetItems.first
	}
}

extension SequenceType where Generator.Element : TimelineTableItem {
	
	func timelineItemsAppend<S: SequenceType where S.Generator.Element == TimelineTableItem>(items: S) -> [S.Generator.Element] {
	
		return self.map { $0 as TimelineTableItem } + items
	}
}
