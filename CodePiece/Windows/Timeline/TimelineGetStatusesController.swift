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
		
		var description: (kind: String, message: String) {
			
			switch error {
				
			case .apiError(let error, _):
				return ("API Error", "\(error)")
				
			case .tweetError(let message):
				return ("Tweet Error", message)
				
			case .parseError(let message, _):
				return ("Parse Error", message)
				
			case .internalError(let message, _):
				return ("Internal Error", message)
				
			case .unexpectedError(let error):
				return ("Unexpected Error", "\(error)")
			}
		}
		
		DebugTime.print("An error occurres when updating timeline (\(description.kind)): \(description.message)")
		
		self.timelineStatusView.errorMessage = description.message
	}
}
