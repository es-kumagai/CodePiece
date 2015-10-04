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

	var status:ESTwitter.Status? {
		
		didSet {
			
			self.applyStatus(self.status)
		}
	}
	
	@IBOutlet var textLabel:NSTextField!
	
	private func applyStatus(status:ESTwitter.Status?) {
		
		if let status = self.status {
			
			self.textLabel.stringValue = status.text
		}
		else {
			
			self.textLabel.stringValue = ""
		}
	}
}
