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
		
		let needAlert = { () -> Bool in
			
			switch error.type {
				
			case .DecodeResultError:
				return true
				
			case .UnexpectedError:
				return true
				
			case .CouldNotAuthenticate:
				return true
				
			case .PageDoesNotExist:
				return true
				
			case .AccountSuspended:
				return true
				
			case .APIv1Inactive:
				return true
				
			case .RateLimitExceeded:
				return false
				
			case .InvalidOrExpiredToken:
				return true
				
			case .SSLRequired:
				return true
				
			case .OverCapacity:
				return false
				
			case .InternalError:
				return true
				
			case .CouldNotAuthenticateYou:
				return false
				
			case .UnableToFollow:
				return true
				
			case .NotAuthorizedToSeeStatus:
				return true
				
			case .DailyStatuUpdateLimitExceeded:
				return true
				
			case .DuplicatedStatus:
				return true
				
			case .BadAuthenticationData:
				return true
				
			case .UserMustVerifyLogin:
				return true
				
			case .RetiredEndpoint:
				return true
				
			case .ApplicationCannotWrite:
				return true
			}
		}
		
		if needAlert() {
			
			self.showErrorAlert("Failed to get Timelines", message: error.description)
		}
		else {
			
			self.timelineStatusView.errorMessage = error.description
		}
	}
}