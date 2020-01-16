//
//  TimelineGetStatusesController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/10.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

protocol TimelineGetStatusesController : AlertDisplayable {
	
	var timelineStatusView: TimelineStatusView! { get }
}

extension TimelineGetStatusesController {
	
	func reportTimelineGetStatusError(error: GetStatusesError) {
		
		self.timelineStatusView.errorMessage = error.description
	}
}