//
//  TimelineViewController+Notifications.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Ocean

extension TimelineViewController {
	
	final class TimelineSelectionChangedNotification : NotificationProtocol {
		
		private(set) unowned var timelineViewController: TimelineViewController
		private(set) var selectedCells: [TimelineTableView.CellInfo]
		
		init(timelineViewController: TimelineViewController, selectedCells: [TimelineTableView.CellInfo]) {
			
			self.timelineViewController = timelineViewController
			self.selectedCells = selectedCells
		}
	}
	
	final class TimelineReplyToSelectionRequestNotification : NotificationProtocol {
		
	}
}
