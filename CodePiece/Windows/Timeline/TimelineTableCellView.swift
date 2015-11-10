//
//  TimelineTableCellView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim
import ESThread
import ESTwitter

class TimelineTableCellView: NSTableCellView, Selectable {

	private static var cellForEstimateHeight: TimelineTableCellView!
	
	enum Style {
	
		case Recent
		case Past
	}
	
	private var _useForEstimateHeightFlag = false
	
	var item:TimelineTweetItem? {
		
		didSet {
			
			self.applyItem(self.item)
		}
	}
	
	var style:Style = .Recent {
		
		didSet {
			
			self.setNeedsDisplayInRect(self.frame)
		}
	}
	
	var selected:Bool = false {
		
		didSet {
			
			if self.selected != oldValue {

				self.textLabel.selectable = self.selected
				self.needsDisplay = true
			}
		}
	}
	
	@IBOutlet var usernameLabel:NSTextField!
	@IBOutlet var textLabel:NSTextField!
	@IBOutlet var iconButton:NSButton!
	@IBOutlet var dateLabel:NSTextField!
	@IBOutlet var retweetMark: NSView!

	override func drawRect(dirtyRect: NSRect) {

		if self.selected {

			self.style.selectionBackgroundColor.set()
		}
		else {

			self.style.backgroundColor.set()
		}
		
		NSRectFill(dirtyRect)
		
		super.drawRect(dirtyRect)
	}
	
	func willSetStatusForEstimateHeightOnce() {
	
		self._useForEstimateHeightFlag = true
	}
	
	private func applyItem(item:TimelineTweetItem?) {
		
		let forEstimateHeight = self._useForEstimateHeightFlag
		
		defer {
			
			self._useForEstimateHeightFlag = false
		}
		
		if let status = self.item?.status {
			
			self.textLabel.stringValue = status.text
			
			if !forEstimateHeight {
			
				let dateToString:(Date) -> String = {
					
					let formatter = tweak(NSDateFormatter()) {
						
						$0.dateStyle = .ShortStyle
						$0.timeStyle = .ShortStyle
//						$0.dateFormat = "yyyy-MM-dd HH:mm"
//						$0.locale = NSLocale(localeIdentifier: "en_US_POSIX")
					}
					
					return formatter.stringFromDate($0.rawValue)
				}
				
				self.usernameLabel.stringValue = status.user.name
				self.dateLabel.stringValue = dateToString(status.createdAt)
				self.iconButton.image = nil
				self.retweetMark.hidden = !status.isRetweetedTweet
				self.style = (status.createdAt > Date().yesterday ? .Recent : .Past)
				
				self.updateIconImage(status)
			}
		}
		else {

			self.usernameLabel.stringValue = ""
			self.textLabel.stringValue = ""
			self.dateLabel.stringValue = ""
			self.iconButton.image = nil
		}
	}
	
	private func updateIconImage(status:ESTwitter.Status) {
		
		// FIXME: 🐬 ここで読み込み済みの画像を使いまわしたり、同じ URL で読み込み中のものがあればそれを待つ処理を実装しないといけない。
		let url = status.user.profile.imageUrlHttps.url!
		
		invokeAsyncInBackground {

			if let image = NSImage(contentsOfURL: url) {
				
				invokeAsyncOnMainQueue {

					self.iconButton.image = image
				}
			}
		}
	}
}

extension TimelineTableCellView : TimelineTableCellType {

	static var prototypeCellIdentifier: String {
		
		return "TimelineCell"
	}

	static func makeCellWithItem(item: TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView {
		
		let view = tweak(self.makeCellForTableView(tableView, owner: owner) as! TimelineTableCellView) {
			
			$0.textLabel.selectable = false
			$0.item = (item as! TimelineTweetItem)
		}
		
		return view
	}
	
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat {

		let item = item as! TimelineTweetItem

		let baseHeight: CGFloat = 61
		let textLabelWidthAdjuster: CGFloat = 10.0

		let cell = self.getCellForEstimateHeightForTableView(tableView)
		
		cell.frame = tableView.rectOfColumn(0)

		let font = cell.textLabel.font
		let labelSize = item.status.text.sizeWithFont(font, lineBreakMode: .ByWordWrapping, maxWidth: cell.textLabel.bounds.width + textLabelWidthAdjuster)

		let textLabelHeight = cell.textLabel.bounds.height
		let estimateHeight = baseHeight + labelSize.height - textLabelHeight

		return estimateHeight
	}
	
	private static func getCellForEstimateHeightForTableView(tableView: NSTableView) -> TimelineTableCellView {
		
		if self.cellForEstimateHeight == nil {
			
//			let cell = self.makeCellForTableView(tableView, owner: self) as! TimelineTableCellView
			guard let topObjects = tableView.topObjectsInRegisteredNibByIdentifier(self.prototypeCellIdentifier) else {
			
				fatalError()
			}
			
			self.cellForEstimateHeight = topObjects.flatMap { $0 as? TimelineTableCellView } .first!
		}
		
		return self.cellForEstimateHeight
	}
}

extension TimelineTableCellView.Style {
	
	var backgroundColor:NSColor {

		switch self {
			
		case .Recent:
			return NSColor.whiteColor()
			
		case .Past:
			return NSColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
		}
	}
	
	var selectionBackgroundColor:NSColor {
		
		switch self {
			
		case .Recent:
			return NSColor(red: 0.858, green: 0.929, blue: 1.000, alpha: 1.0)
			
		case .Past:
			return NSColor(red: 0.858, green: 0.858, blue: 1.000, alpha: 1.0)
		}
	}
}