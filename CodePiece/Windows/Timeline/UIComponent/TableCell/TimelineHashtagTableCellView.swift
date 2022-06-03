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

struct TimelineHashtagTableCellItem {

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
	
@IBDesignable
@objcMembers
@MainActor
final class TimelineHashtagTableCellView: NSTableCellView {

	var item = TimelineHashtagTableCellItem(previousHashtags: nil, currentHashtags: []) {
	
		didSet {

			previousHashtagLabel.stringValue = item.previousHashtags?.twitterDisplayText ?? ""
			currentHashtagLabel.stringValue = item.currentHashtags.twitterDisplayText
			
			previousHashtagView.isHidden = (item.previousHashtags == nil)
		}
	}
	
	var selected: Bool = false
	
	@IBOutlet var previousHashtagLabel: NSTextField!
	@IBOutlet var currentHashtagLabel: NSTextField!
	@IBOutlet var previousHashtagView: NSView!
	@IBOutlet var currentHashtagView: NSView!
	
	@IBInspectable var backgroundColor: NSColor?
	
	override func draw(_ dirtyRect: NSRect) {
		
		switch backgroundColor {
			
		case .some(let color):
			color.set()
			
		case .none:
			NSColor.white.set()
		}
	
		dirtyRect.fill()
		
		super.draw(dirtyRect)
	}
}

extension NSUserInterfaceItemIdentifier {
	
	static var timelineHashtagCell = NSUserInterfaceItemIdentifier(rawValue: "TimelineHashtagCell")
}

extension TimelineHashtagTableCellView : TimelineTableCellType {
	
	static var userInterfaceItemIdentifier: NSUserInterfaceItemIdentifier = .timelineHashtagCell
	
	static func makeCellWithItem(item: TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView {
		
		let rawView = makeCellForTableView(tableView: tableView, owner: owner)
		
		guard let view = rawView as? TimelineHashtagTableCellView else {
			
			fatalError("Unexpected cell type: \(type(of: rawView))")
		}
		
		guard let item = item as? TimelineHashtagTableCellItem else {
			
			fatalError("Unexpected TableView item passed.")
		}
		
		view.item = item
		
		return view
	}
	
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat {
		
		return 20.0
	}
}
