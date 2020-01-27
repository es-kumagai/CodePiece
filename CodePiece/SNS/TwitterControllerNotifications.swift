//
//  TwitterControllerNotification.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Ocean
import ESTwitter

extension TwitterController {
	
	struct AuthorizationStateDidChangeNotification : NotificationProtocol {
		
		var isAuthorized: Bool
		var screenName: String?
	}
	
	struct AuthorizationStateDidChangeWithErrorNotification : NotificationProtocol {
		
		var error: AuthorizationError
	}
	
	struct AuthorizationStateInvalidNotification : NotificationProtocol {		
	}
	
	struct AuthorizationResetSucceededNotification : NotificationProtocol {
		
	}
	
	struct AuthorizationResetFailureNotification : NotificationProtocol {
		
		public var error: APIError
	}
	
	struct CredentialsVerifySucceededNotification : NotificationProtocol {
		
	}
	
	struct CredentialsVerifyFailureNotification : NotificationProtocol {
		
		public var error: APIError
	}
}
