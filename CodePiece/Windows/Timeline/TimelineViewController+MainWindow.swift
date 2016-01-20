//
//  TimelineViewController+MainWindow.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESNotification

extension TimelineViewController {
	
	var canReplyRequest: Bool {
	
		return timelineTableView.selectedAnyRows
	}
	
	@IBAction func replyRequest(sender: AnyObject) {
		
		TimelineReplyToSelectionRequestNotification().post()
	}
}