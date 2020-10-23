//
//  PostError.swift
//  CodePieceCore
//
//  Created by kumagai on 2020/05/26.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import ESTwitter

extension SNSController {
	
	/// This means a error which may occur when post.
	public enum PostError : Error {
		
		public enum State {
			
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

extension PostError.State {
	
	var isUnidentifiable: Bool {
		
		if case .unidentifiable = self {
			
			return true
		}
		else {
			
			return false
		}
	}
}
