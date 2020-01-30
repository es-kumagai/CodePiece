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
			return "\(error.localizedDescription)"
		}
	}
}

extension ESTwitter.PostError {
	
	public var localizedDescription: String {
		
		func messageHeader(for state: State) -> String {
			
			switch state {
				
			case .beforePosted:
				return ""
				
			case .afterPosted:
				return "Tweet has been posted but after that, following error occurred: "
				
			case .noPost:
				return ""
			}
		}
		
		switch self {
			
		case .apiError(let error, let state):
			return messageHeader(for: state) + error.localizedDescription

		case .tweetError(let message):
			return "\(message)"
			
		case .parseError(let message, let state):
			return messageHeader(for: state) + "Failed to parse JSON. \(message)"
			
		case .internalError(let message, let state):
			return messageHeader(for: state) + "Internal Error: \(message)"
			
		case .unexpectedError(let error, let state):
			return messageHeader(for: state) + error.localizedDescription
		}
	}
}
