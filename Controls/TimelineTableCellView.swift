//
//  TimelineTableCellView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

class TimelineTableCellView: NSTableCellView {

	private var _useForEstimateHeightFlag = false
	
	var status:ESTwitter.Status? {
		
		didSet {
			
			self.applyStatus(self.status)
		}
	}
	
	@IBOutlet var textLabel:NSTextField!
	
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
		}
		else {
			
			self.textLabel.stringValue = ""
		}
	}
}
