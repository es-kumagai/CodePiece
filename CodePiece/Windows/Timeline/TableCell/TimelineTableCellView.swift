//
//  TimelineTableCellView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Swim
import ESTwitter
import ESGists

@objcMembers
final class TimelineTableCellView: NSTableCellView, Selectable {

	private static var cellForEstimateHeight: TimelineTableCellView!
	
	enum Style {
	
		case Recent
		case Past
	}
	
	var item: TimelineTweetItem? {
		
		didSet {
			
			if item != oldValue {

				applyItem(item: item)
			}
		}
	}
	
	var style: Style = .Recent {
		
		didSet {
			
			self.needsDisplay = true
		}
	}
	
	var selected: Bool = false {
		
		didSet {
			
			if self.selected != oldValue {

				self.textLabel.isSelectable = self.selected
				self.needsDisplay = true
			}
		}
	}
	
	@IBOutlet var usernameLabel:NSTextField!
	@IBOutlet var textLabel:NSTextField!
	@IBOutlet var iconButton:NSButton!
	@IBOutlet var dateLabel:NSTextField!
	@IBOutlet var retweetMark: NSView!

	override func draw(_ dirtyRect: NSRect) {

		if self.selected {

			self.style.selectionBackgroundColor.set()
		}
		else {

			self.style.backgroundColor.set()
		}
		
		dirtyRect.fill()
		
		super.draw(dirtyRect)
	}
	
	private func applyItem(item: TimelineTweetItem?) {

		if let status = item?.status {

			// NOTE: 🐬 CodePiece の Data を扱うときに HTMLText を介すると attributedText の実装が逆に複雑化する可能性があるため、一旦保留にします。
//			let html = HTMLText(rawValue: status.text)
//			self.textLabel.attributedStringValue = html.attributedText

			
			
			textLabel.attributedStringValue = status.attributedText { text in

				let textRange = NSMakeRange(0, text.length)

				text.addAttribute(.font, value: NSFont.textFont, range: textRange)
				text.addAttribute(.foregroundColor, value: NSColor.textColor, range: textRange)
			}
			
			usernameLabel.stringValue = status.user.name
			dateLabel.stringValue = status.createdAt.description
			iconButton.image = nil
			retweetMark.isHidden = !status.isQuoteStatus
			style = (status.createdAt > TwitterDate(NSDate().daysAgo(1) as Foundation.Date) ? .Recent : .Past)

			updateIconImage(status: status)
		}
		else {

			self.textLabel.attributedStringValue = NSAttributedString(string: "")
			self.usernameLabel.stringValue = ""
			self.dateLabel.stringValue = ""
			self.iconButton.image = nil
			self.retweetMark.isHidden = true
			self.style = .Recent
			self.iconButton.image = nil
		}
		
		self.needsDisplay = true
	}
	
	private func updateIconImage(status: ESTwitter.Status) {

		let setImage = { (url: Foundation.URL) in
			
			DispatchQueue.global(qos: .background).async {
				
				if let image = NSImage(contentsOf: url) {
					
					DispatchQueue.main.async { self.iconButton.image = image }
				}
				else {
					
					DispatchQueue.main.async { self.iconButton.image = nil }
				}
			}
		}
		
		let resetImage = {
			
			DispatchQueue.main.async {
				
				self.iconButton.image = nil
			}
		}
		
		// FIXME: 🐬 ここで読み込み済みの画像を使いまわしたり、同じ URL で読み込み中のものがあればそれを待つ処理を実装しないといけない。
		if let url = status.user.profile.imageUrlHttps.url {

			setImage(url)
		}
		else {

			resetImage()
		}
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
	
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat {

		let item = item as! TimelineTweetItem

		let baseHeight: CGFloat = 61
		let textLabelWidthAdjuster: CGFloat = 10.0

		let cell = self.getCellForEstimateHeightForTableView(tableView: tableView)
		
		cell.frame = tableView.rect(ofColumn: 0)

		let font = cell.textLabel.font
		let labelSize = item.status.text.size(with: font, lineBreakMode: .byWordWrapping, maxWidth: cell.textLabel.bounds.width + textLabelWidthAdjuster)

		let textLabelHeight = cell.textLabel.bounds.height
		let estimateHeight = baseHeight + labelSize.height - textLabelHeight

		return estimateHeight
	}
	
	private static func getCellForEstimateHeightForTableView(tableView: NSTableView) -> TimelineTableCellView {
		
		if cellForEstimateHeight == nil {
			
//			let cell = self.makeCellForTableView(tableView, owner: self) as! TimelineTableCellView
			guard let topObjects = tableView.topObjectsInRegisteredNibByIdentifier(identifier: userInterfaceItemIdentifier) else {
			
				fatalError()
			}
			
			cellForEstimateHeight = topObjects
				.compactMap { $0 as? TimelineTableCellView }
				.first!
		}
		
		return self.cellForEstimateHeight
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
