//
//  SNSControllerPostError.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import ESTwitter

extension SNSController {
	
	/// This means a error which may occur when post.
	enum PostError : Error {
		
		case Unexpected(Error)
		case SystemError(String)
		case Description(String)
		case Authentication(AuthenticationError)
		//		case PostTextTooLong(limit: Int)
		case FailedToUploadMedia(reason: String)
		case twitterError(ESTwitter.PostError)
	}
}

extension SNSController.PostError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .Unexpected(let error):
			return "Unexpected Error: \(error.localizedDescription)"
			
		case .SystemError(let message):
			return "System Error: \(message)"
			
		case .Description(let message):
			return "\(message)"
			
		case .Authentication(let error):
			return "Authentication Error: \(error.localizedDescription)"
			
		case .FailedToUploadMedia(reason: let reason):
			return "Failed to upload the media. \(reason)"
			
		case .twitterError(let error):
			return "Failed to post the tweet. \(error.localizedDescription)"
		}
	}
}

extension ESTwitter.PostError {
	
	public var localizedDescription: String {
		
		switch self {
			
		case .apiError(let error):
			return error.localizedDescription

		case .tweetError(let message):
			return "\(message)"
			
		case .parseError(let message):
			return "Failed to parse JSON. \(message)"
			
		case .internalError(let message):
			return "Internal Error: \(message)"
			
		case .unexpected(let error):
			return error.localizedDescription
		}
	}
}
