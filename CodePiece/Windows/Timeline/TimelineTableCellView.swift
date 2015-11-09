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

	enum Style {
	
		case Recent
		case Past
	}
	
	private var _useForEstimateHeightFlag = false
	
	var status:ESTwitter.Status? {
		
		didSet {
			
			self.applyStatus(self.status)
		}
	}
	
	var style:Style = .Recent {
		
		didSet {
			
			self.setNeedsDisplayInRect(self.frame)
		}
	}
	
	var selected:Bool = false {
		
		didSet {
			
			self.textLabel.selectable = self.selected
			self.setNeedsDisplayInRect(self.frame)
		}
	}
	
	@IBOutlet weak var usernameLabel:NSTextField!
	@IBOutlet weak var textLabel:NSTextField!
	@IBOutlet weak var iconButton:NSButton!
	@IBOutlet weak var dateLabel:NSTextField!
	
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
	
	private func applyStatus(status:ESTwitter.Status?) {
		
		let forEstimateHeight = self._useForEstimateHeightFlag
		
		defer {
			
			self._useForEstimateHeightFlag = false
		}
		
		if let status = self.status {
			
			self.textLabel.stringValue = status.text
			
			if !forEstimateHeight {
			
				let dateToString:(Date) -> String = {
					
					let formatter = tweak(NSDateFormatter()) {
						
						$0.dateFormat = "yyyy-MM-dd HH:mm"
						$0.locale = NSLocale(localeIdentifier: "en_US_POSIX")
					}
					
					return formatter.stringFromDate($0.rawValue)
				}
				
				self.usernameLabel.stringValue = status.user.name
				self.dateLabel.stringValue = dateToString(status.createdAt)
				self.iconButton.image = nil
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
			$0.status = (item as! ESTwitter.Status)
		}
		
		return view
	}
	
	static func estimateCellHeightForItem(item:TimelineTableItem, tableView:NSTableView) -> CGFloat {
	
		// 現行では、実際にビューを作ってサイズを確認しています。
		let view = tweak(self.makeCellForTableView(tableView, owner: self) as! TimelineTableCellView) {
			
			$0.willSetStatusForEstimateHeightOnce()
			$0.status = (item as! ESTwitter.Status)
			
			let size = $0.fittingSize
			
			$0.bounds = NSMakeRect(0, 0, size.width, size.height)
		}
		
		return view.fittingSize.height
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