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

class TimelineTableCellView: NSTableCellView, Selectable {

	private static var cellForEstimateHeight: TimelineTableCellView!
	
	enum Style {
	
		case Recent
		case Past
	}
	
	var item:TimelineTweetItem? {
		
		didSet {
			
			if item?.status.id != oldValue?.status.id {

				self.applyItem(item: self.item)
			}
		}
	}
	
	var style:Style = .Recent {
		
		didSet {
			
			self.needsDisplay = true
		}
	}
	
	var selected:Bool = false {
		
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
	
	private func applyItem(item:TimelineTweetItem?) {

		if let status = item?.status {

			// NOTE: 🐬 CodePiece の Data を扱うときに HTMLText を介すると attributedText の実装が逆に複雑化する可能性があるため、一旦保留にします。
//			let html = HTMLText(rawValue: status.text)
//			self.textLabel.attributedStringValue = html.attributedText

			self.textLabel.attributedStringValue = status.attributedText { text in
				
				let textRange = NSMakeRange(0, text.length)
				
				text.addAttribute(.font, value: systemPalette.textFont, range: textRange)
				text.addAttribute(.foregroundColor, value: systemPalette.textColor, range: textRange)
			}
			
			self.usernameLabel.stringValue = status.user.name
			self.dateLabel.stringValue = status.createdAt.description
			self.iconButton.image = nil
			self.retweetMark.isHidden = !status.isRetweetedTweet
			self.style = (status.createdAt > Date().daysAgo(1) ? .Recent : .Past)
			
			self.updateIconImage(status: status)
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
	
	private func updateIconImage(status:ESTwitter.Status) {

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

	static func makeCellWithItem(item: TimelineTableItem, tableView: NSTableView, owner: AnyObject?) -> NSTableCellView {
		
		let view = applyingExpression(to: makeCellForTableView(tableView: tableView, owner: owner) as! TimelineTableCellView) {
			
			$0.textLabel.isSelectable = false
			$0.textLabel.allowsEditingTextAttributes = true
			
			$0.item = (item as! TimelineTweetItem)
		}
		
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
		
		if self.cellForEstimateHeight == nil {
			
//			let cell = self.makeCellForTableView(tableView, owner: self) as! TimelineTableCellView
			guard let topObjects = tableView.topObjectsInRegisteredNibByIdentifier(identifier: .timelineHashtagTableCellViewPrototypeCellIdentifier) else {
			
				fatalError()
			}
			
			self.cellForEstimateHeight = topObjects.compactMap { $0 as? TimelineTableCellView } .first!
		}
		
		return self.cellForEstimateHeight
	}
}

extension TimelineTableCellView.Style {
	
	var backgroundColor:NSColor {

		switch self {

		case .Recent:
			return .white
			
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
