//
//  TimelineHashtagTableCellView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/09.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim
import ESTwitter

struct TimelineHashtagTableCellItem{

	var previousHashtags: HashtagSet?
	var currentHashtags: HashtagSet
	
	init(previousHashtags: HashtagSet?, currentHashtags: HashtagSet) {
		
		self.previousHashtags = previousHashtags
		self.currentHashtags = currentHashtags
	}
}

extension TimelineHashtagTableCellItem : TimelineTableItem  {
	
	var timelineItemTweetId: String? {
		
		return nil
	}
	
	var timelineCellType: TimelineTableCellType.Type {
		
		return TimelineHashtagTableCellView.self
	}
}
	
@IBDesignable final class TimelineHashtagTableCellView: NSTableCellView {

	var item = TimelineHashtagTableCellItem(previousHashtags: nil, currentHashtags: []) {
	
		didSet {

			self.previousHashtagLabel.stringValue = self.item.previousHashtags?.toTwitterDisplayText() ?? ""
			self.currentHashtagLabel.stringValue = self.item.currentHashtags.toTwitterDisplayText()
			
			self.previousHashtagView.isHidden = (self.item.previousHashtags == nil)
		}
	}
	
	var selected: Bool = false
	
	@IBOutlet var previousHashtagLabel: NSTextField!
	@IBOutlet var currentHashtagLabel: NSTextField!
	@IBOutlet var previousHashtagView: NSView!
	@IBOutlet var currentHashtagView: NSView!
	
	@IBInspectable var backgroundColor: NSColor?
	
	override func drawRect(dirtyRect: NSRect) {
		
		tweak(self.backgroundColor ?? NSColor.whiteColor()) {
			
			$0.set()
		}
		
		NSRectFill(dirtyRect)
		
		super.drawRect(dirtyRect)
	}
}

extension TimelineHashtagTableCellView : TimelineTableCellType {
	
	static var prototypeCellIdentifier: String {
		
		return "TimelineHashtagCell"
	}
	
	static func makeCellWithItem(item: TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView {
		
		let view = tweak(self.makeCellForTableView(tableView, owner: owner) as! TimelineHashtagTableCellView) {
			
			$0.item = (item as! TimelineHashtagTableCellItem)
		}
		
		return view
	}
	
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat {
		
		return 20.0
	}
}
