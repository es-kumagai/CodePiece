//
//  TimelineGetStatusesController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/10.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESTwitter

protocol TimelineGetStatusesController : AlertDisplayable {
	
	var timelineStatusView: TimelineStatusView! { get }
}

extension TimelineGetStatusesController {
	
	func reportTimelineGetStatusError(error: PostError) {
		
		self.timelineStatusView.errorMessage = "\(error)"
	}
}
