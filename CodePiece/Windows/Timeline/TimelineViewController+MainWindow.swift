//
//  TimelineViewController+MainWindow.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean

extension TimelineViewController {
	
	var canReplyRequest: Bool {
	
		return timelineTableView.selectedAnyRows
	}
	
	@IBAction func replyRequest(sender: AnyObject) {
		
		TimelineReplyToSelectionRequestNotification().post()
	}
	
	var canOpenBrowserWithCurrentTwitterStatus: Bool {
		
		return timelineTableView.selectedSingleRow
	}
	
	@IBAction func openBrowserWithCurrentTwitterStatus(sender: AnyObject) {
		
		self.menuController.openBrowserWithCurrentTwitterStatus(sender: sender)
	}
}
