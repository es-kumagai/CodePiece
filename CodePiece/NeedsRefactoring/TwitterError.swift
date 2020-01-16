//
//  TwitterError.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 9/9/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

extension STTwitterTwitterErrorCode : CustomStringConvertible {
	
	public var description: String {

		switch self {
			
		case .accountSuspended:
			return "Account suspended."
			
		case .apiV1Inactive:
			return "APIv1 inactive."

		case .applicationCannotWrite:
			return "Application cannot write."
			
		case .badAuthenticationData:
			return "Bad authentication data."
			
		case .couldNotAuthenticate:
			return "Could not authenticate."
			
		case .couldNotAuthenticateYou:
			return "Could not authenticate you."
			
		case .dailyStatuUpdateLimitExceeded:
			return "Daily status update limit exceeded."
			
		case .duplicatedStatus:
			return "Duplicated status."
			
		case .internalError:
			return "Internal error."
			
		case .invalidOrExpiredToken:
			return "Invalid or expired token."
			
		case .notAuthorizedToSeeStatus:
			return "Not authorized to see status."
			
		case .overCapacity:
			return "Over capacity."
			
		case .pageDoesNotExist:
			return "Page does not exist."
			
		case .rateLimitExceeded:
			return "Rate limit exceeded."
			
		case .retiredEndpoint:
			return "Retired endpoint."
			
		case .sslRequired:
			return "SSL required."
			
		case .unableToFollow:
			return "Unable to follow."
			
		case .userMustVerifyLogin:
			return "User must verify login."
		}
	}
}
