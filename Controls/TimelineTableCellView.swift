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

class TimelineTableCellView: NSTableCellView {

	private var _useForEstimateHeightFlag = false
	
	var status:ESTwitter.Status? {
		
		didSet {
			
			self.applyStatus(self.status)
		}
	}
	
	@IBOutlet var usernameLabel:NSTextField!
	@IBOutlet var textLabel:NSTextField!
	@IBOutlet var iconButton:NSButton!
	@IBOutlet var dateLabel:NSTextField!
	
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
