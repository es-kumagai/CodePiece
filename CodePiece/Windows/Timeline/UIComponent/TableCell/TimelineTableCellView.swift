//
//  TimelineTableCellView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Swim
import Ocean
import ESTwitter
import ESGists

@objcMembers
final class TimelineTableCellView: NSTableCellView, Selectable, NotificationObservable {

	private static var cellForEstimateHeight: TimelineTableCellView!
	
	var notificationHandlers = Notification.Handlers()
	
	enum Style {
	
		case Recent
		case Past
	}
	
	var item: TimelineTweetItem? {
		
		didSet {
			
			if item != oldValue {

				applyItem()
			}
		}
	}
	
	var style: Style = .Recent {
		
		didSet {
			
			needsDisplay = true
		}
	}
	
	var selected: Bool = false {
		
		didSet {
			
			if selected != oldValue {

				textLabel.isSelectable = selected
				needsDisplay = true
			}
		}
	}
	
	@IBOutlet var usernameLabel: NSTextField!
	@IBOutlet var textLabel: NSTextField!
	@IBOutlet var iconButton: NSButton!
	@IBOutlet var dateLabel: NSTextField!
	@IBOutlet var retweetMark: NSView!

	override func draw(_ dirtyRect: NSRect) {

		if selected {

			style.selectionBackgroundColor.set()
		}
		else {

			style.backgroundColor.set()
		}
		
		dirtyRect.fill()
		
		super.draw(dirtyRect)
	}
	
	override func awakeFromNib() {
		
		super.awakeFromNib()

		observe(TwitterIconLoader.TwitterIconDidLoadNotification.self) { [unowned self] notification in

			guard item?.status.user == notification.user else {
				
				return
			}

			iconButton.image = notification.icon
			NSLog("%@", "\(notification.user.screenName)'s icon did load.")
		}
	}
	
	private func applyItem() {

		if let status = item?.status {

			// NOTE: 🐬 CodePiece の Data を扱うときに HTMLText を介すると attributedText の実装が逆に複雑化する可能性があるため、一旦保留にします。
//			let html = HTMLText(rawValue: status.text)
//			textLabel.attributedStringValue = html.attributedText

			
			
			textLabel.attributedStringValue = status.attributedText { text in

				let textRange = NSMakeRange(0, text.length)

				text.addAttribute(.font, value: NSFont.textFont, range: textRange)
				text.addAttribute(.foregroundColor, value: NSColor.textColor, range: textRange)
			}
			
			usernameLabel.stringValue = status.user.name
			dateLabel.stringValue = status.createdAt.description
			retweetMark.isHidden = !status.isQuoteStatus
			style = (status.createdAt > TwitterDate(NSDate().daysAgo(1) as Foundation.Date) ? .Recent : .Past)
			iconButton.image = twitterIconLoader.requestImage(for: status.user).image
		}
		else {

			textLabel.attributedStringValue = NSAttributedString(string: "")
			usernameLabel.stringValue = ""
			dateLabel.stringValue = ""
			iconButton.image = nil
			retweetMark.isHidden = true
			style = .Recent
			iconButton.image = nil
		}
		
		needsDisplay = true
	}
}

extension TimelineTableCellView : TimelineTableCellType {

	static var userInterfaceItemIdentifier: NSUserInterfaceItemIdentifier = .timeLineCell
	
	static func makeCellWithItem(item: TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView {

		guard let tweetItem = item as? TimelineTweetItem else {
			
			fatalError("Unexpected table item. Expected `TimeLineTweetItem` but actual `\(type(of: item))`")
		}
		
		let view = makeCellForTableView(tableView: tableView, owner: owner) as! TimelineTableCellView
		
		view.textLabel.isSelectable = false
		view.textLabel.allowsEditingTextAttributes = true

		view.item = tweetItem
		
		return view
	}
	
	static func estimateCellHeightForItem(item: TimelineTableItem, tableView:NSTableView) -> CGFloat {

		let item = item as! TimelineTweetItem

		let baseHeight: CGFloat = 61
		let textLabelWidthAdjuster: CGFloat = 10.0

		let cell = getCellForEstimateHeightForTableView(tableView: tableView)
		
		cell.frame = tableView.rect(ofColumn: 0)

		let font = cell.textLabel.font
		let labelSize = item.status.text.size(with: font, lineBreakMode: .byWordWrapping, maxWidth: cell.textLabel.bounds.width + textLabelWidthAdjuster)

		let textLabelHeight = cell.textLabel.bounds.height
		let estimateHeight = baseHeight + labelSize.height - textLabelHeight

		return estimateHeight
	}
	
	private static func getCellForEstimateHeightForTableView(tableView: NSTableView) -> TimelineTableCellView {
		
		if cellForEstimateHeight == nil {
			
			guard let topObjects = tableView.topObjectsInRegisteredNibByIdentifier(identifier: userInterfaceItemIdentifier) else {
			
				fatalError()
			}
			
			cellForEstimateHeight = topObjects
				.compactMap { $0 as? TimelineTableCellView }
				.first!
		}
		
		return cellForEstimateHeight
	}
}

extension TimelineTableCellView.Style {
	
	var backgroundColor: NSColor {

		switch self {

		case .Recent:
			return .recentBackgroundColor
			
		case .Past:
			return .pastBackgroundColor
		}
	}
	
	var selectionBackgroundColor: NSColor {
		
		switch self {
			
		case .Recent:
			return .recentSelectionBackgroundColor
			
		case .Past:
			return .pastSelectionBackgroundColor
		}
	}
}
