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
	
		return isTimelineSingleRowSelected
	}
	
	@IBAction func replyRequest(_ sender: AnyObject) {
		
		TimelineReplyToSelectionRequestNotification().post()
	}
	
	var canOpenBrowserWithCurrentTwitterStatus: Bool {

		return isTimelineSingleRowSelected
	}
	
	@IBAction func openBrowserWithCurrentTwitterStatus(_ sender: AnyObject) {
		
		menuController.openBrowserWithCurrentTwitterStatus(sender)
	}
}
