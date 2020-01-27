//
//  Error.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

public enum PostError : Error {
	
	case apiError(APIError)
	case tweetError(String)
	case parseError(String)
	case internalError(String)
	case unexpected(Error)
}

extension PostError {
	
	init(tweetError error: SwifterError) {

		switch error.kind {
			
		case let .urlResponseError(_, _, errorCode):
			
			switch errorCode {
				
			case 187:
				self = .tweetError("Status is a duplicate.")
				
			default:
				self = .tweetError(error.message)
			}
			
		default:
			self = .tweetError(error.message)
		}
	}
}
