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
		
		let isCredentialVerified: Bool
		let screenName: String?
	}
	
	struct AuthorizationStateDidChangeWithErrorNotification : NotificationProtocol {
		
		let error: AuthorizationError
	}
	
	struct AuthorizationStateInvalidNotification : NotificationProtocol {		
	}
	
	struct AuthorizationResetSucceededNotification : NotificationProtocol {
		
	}
	
	struct AuthorizationResetFailureNotification : NotificationProtocol {
		
		let error: APIError
	}
	
	struct CredentialsVerifySucceededNotification : NotificationProtocol {
		
	}
	
	struct CredentialsVerifyFailureNotification : NotificationProtocol {
		
		let error: APIError
	}
}
