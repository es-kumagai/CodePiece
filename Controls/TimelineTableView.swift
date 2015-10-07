//
//  TimelineTableView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/07.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class TimelineTableView: NSTableView {

	func timelineTableDataSource() -> TimelineTableDataSource {
		
		return super.dataSource() as! TimelineTableDataSource
	}
	
	override func resizeWithOldSuperviewSize(oldSize: NSSize) {
		
		super.resizeWithOldSuperviewSize(oldSize)
		
		self.timelineTableDataSource().setNeedsEstimateHeight()
		self.reloadData()
	}
}
