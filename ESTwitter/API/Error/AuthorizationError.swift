//
//  Error.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

public enum AuthorizationError : Error {
	
	case apiError(APIError)
	case notAuthorized(message: String)
	case failedToGetAccessToken(URLResponse)
	case unknownError(Error)
}

extension AuthorizationError : CustomStringConvertible {
	
	public var description: String {
		
		switch self {
			
		case .apiError(let error):
			return "\(error)"
			
		case .notAuthorized(let message):
			return "Not authorized. \(message)"
			
		case .failedToGetAccessToken(let response):
			return "Failed to get an access token. \(response.description)"
			
		case .unknownError(let error):
			return "Unknown error: \(error.localizedDescription)"
		}
	}
}
