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
		
		enum State {
			
			case occurred(on: PostDataContainer.PostStage)
			case postGistDirectly
			case postMediaDirectly
			case postTweetDirectly
			case unidentifiable
		}
		
		case unexpected(Error, state: State)
		case systemError(String, state: State)
		case description(String, state: State)
		case authentication(AuthenticationError, state: State)
		//		case PostTextTooLong(limit: Int)
		case failedToUploadMedia(reason: String, state: State)
		case twitterError(ESTwitter.PostError, state: State)
		case postError(String, state: State)
	}
}

extension SNSController.PostError : CustomStringConvertible {

//	func stateChanged(to newState: State) -> SNSController.PostError {
//
//		switch self {
//
//		case .Unexpected(let error, state: _):
//			return .Unexpected(error, state: newState)
//
//		case .SystemError(let message, state: _):
//			return .SystemError(message, state: newState)
//
//		case .Description(let message, state: _):
//			return .Description(message, state: newState)
//
//		case .Authentication(let error, state: _):
//			return .Authentication(error, state: newState)
//
//		case .FailedToUploadMedia(let reason, state: _):
//			return .FailedToUploadMedia(reason: reason, state: newState)
//
//		case .twitterError(let error, state: _):
//			return .twitterError(error, state: newState)
//
//		case .postError(let message, state: _):
//			return .postError(message, state: newState)
//		}
//	}
	
	var description: String {
		
		func prefix(for state: State) -> String {
			
			guard
				!state.isUnidentifiable,
				case let .occurred(stage) = state else {
					
				return ""
			}
		
			let allStages = PostDataContainer.PostStage.allCases
			
			guard allStages.first != stage else {
				
				return ""
			}
			
			let indexOfCurrentStage = allStages.firstIndex(of: stage)!
			let passedStage = allStages[indexOfCurrentStage - 1]
			
			switch passedStage {
				
			case .initialized:
				return ""

			case .postToGists, .captureGists:
				return "Posted gist, but following error occurred: "

			case .postProcessToTwitter, .postToTwitterMedia:
				return "Posted gist, but following error occurred: "

			case .postToTwitterStatus, .posted:
				return "All items posted completely, but following error occurred: "
			}
		}
		
		switch self {
			
		case .unexpected(_, let state),
			 .systemError(_, let state),
			 .description(_, let state),
			 .authentication(_, let state),
			 .failedToUploadMedia(_, let state),
			 .twitterError(_, let state),
			 .postError(_, let state):

			return prefix(for: state) + descriptionWithoutState
		}
	}
	
	var descriptionWithoutState: String {
		
		switch self {
			
		case .unexpected(let error, _):
			return "Unexpected error: \(error)"
			
		case .systemError(let message, _):
			return "System Error: \(message)"
			
		case .description(let message, _):
			return message
			
		case .authentication(let error, _):
			return "Authentication Error: \(error)"
			
		case .failedToUploadMedia(let reason, _):
			return "Failed to upload the media. \(reason)"
			
		case .twitterError(let error, _):
			return "\(error)"
			
		case .postError(let message, _):
			return "System Error: \(message)"
		}
	}
}

extension GetStatusesError : CustomStringConvertible {
	
	public var description: String {

		switch self {
			
		case .apiError(let error):
			return "\(error)"
			
		case .parseError(let message):
			return message
			
		case .unexpected(let error):
			return "Unexpected error: \(error)"
			
		case .unexpectedWithDescription(let message):
			return "Unexpected error: \(message)"

		case .genericError(let message):
			return message
			
		case .responseError(code: let code, message: let message):
			return "\(message) (\(code))"
			
		case .internalError:
			return "Internal error."
			
		case .rateLimitExceeded:
			return "Late limit exceeded."
			
		case .missingOrInvalidUrlParameter:
			return "Missing or invalid url parameter."
		}
	}
}

extension SNSController.PostError.State {

	var isUnidentifiable: Bool {

		if case .unidentifiable = self {
			
			return true
		}
		else {
			
			return false
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
				
//			case .withNoPostProcess:
//				return ""
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
