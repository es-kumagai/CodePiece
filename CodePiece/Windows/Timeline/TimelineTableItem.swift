//
//  TimelineTableItem.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/09.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import Swim
import ESTwitter

protocol TimelineTableItem {
	
	var timelineItemTweetId: String? { get }
	var timelineCellType: TimelineTableCellType.Type { get }
}

protocol TimelineTableCellType {
	
	static var prototypeCellIdentifier: String { get }
	
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat

	static func makeCellWithItem(item:TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView
}

extension TimelineTableCellType {
	
	static func makeCellForTableView(tableView: NSTableView, owner: AnyObject?) -> TimelineTableCellType {

		return tableView.makeViewWithIdentifier(self.prototypeCellIdentifier, owner: owner) as! TimelineTableCellType
	}
}

extension ESTwitter.Status : TimelineTableItem {
	
	var timelineItemTweetId: String? {
		
		return self.idStr
	}
	
	var timelineCellType: TimelineTableCellType.Type {
		
		return TimelineTableCellView.self
	}
}

extension SequenceType where Generator.Element == TimelineTableItem {
	
	var timelineItemFirstTweetId: String? {

		let validTweetIds = self.flatMap { $0.timelineItemTweetId }
		
		return validTweetIds.first
	}
}

extension SequenceType where Generator.Element : TimelineTableItem {
	
	func timelineItemsAppend<S: SequenceType where S.Generator.Element == TimelineTableItem>(items: S) -> [S.Generator.Element] {
	
		return self.map { $0 as TimelineTableItem } + items
	}
}
