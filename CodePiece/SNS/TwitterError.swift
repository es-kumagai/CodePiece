//
//  TwitterError.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 9/9/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import STTwitter

extension STTwitterTwitterErrorCode : CustomStringConvertible {
	
	public var description: String {

		switch self {
			
		case .AccountSuspended:
			return "Account suspended."
			
		case .APIv1Inactive:
			return "APIv1 inactive."

		case .ApplicationCannotWrite:
			return "Application cannot write."
			
		case .BadAuthenticationData:
			return "Bad authentication data."
			
		case .CouldNotAuthenticate:
			return "Could not authenticate."
			
		case .CouldNotAuthenticateYou:
			return "Could not authenticate you."
			
		case .DailyStatuUpdateLimitExceeded:
			return "Daily status update limit exceeded."
			
		case .DuplicatedStatus:
			return "Duplicated status."
			
		case .InternalError:
			return "Internal error."
			
		case .InvalidOrExpiredToken:
			return "Invalid or expired token."
			
		case .NotAuthorizedToSeeStatus:
			return "Not authorized to see status."
			
		case .OverCapacity:
			return "Over capacity."
			
		case .PageDoesNotExist:
			return "Page does not exist."
			
		case .RateLimitExceeded:
			return "Rate limit exceeded."
			
		case .RetiredEndpoint:
			return "Retired endpoint."
			
		case .SSLRequired:
			return "SSL required."
			
		case .UnableToFollow:
			return "Unable to follow."
			
		case .UserMustVerifyLogin:
			return "User must verify login."
		}
	}
}