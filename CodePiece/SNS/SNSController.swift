//
//  SNSController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import ESGists
import ESTwitter

protocol PostController {

	var canPost:Bool { get }
}

final class SNSController : PostController {

	enum Service {
	
		case Twitter
		case GitHub
	}
	
	enum AuthenticationError : Error {
		
		case CredentialsNotVerified
		case NotAuthorized(service: Service)
		case NotReady(service: Service, description: String)
		case InvalidAccount(service: Service, reason: String)
	}
	
	/// This means a error which may occur when post.
	enum PostError : Error {
		
		case Unexpected(NSError)
		case SystemError(String)
		case Description(String)
		case Authentication(AuthenticationError)
		case PostTextTooLong(limit: Int)
		case FailedToUploadGistCapture(NSImage, description: String)
		case FailedToPostTweet(String)
	}
	
	var gists:GistsController
	var twitter:TwitterController
	
	init() {

		self.gists = GistsController()
		self.twitter = TwitterController()
	}
	
	var canPost:Bool {
	
		return gists.canPost && twitter.canPost
	}
	
	func post(container:PostDataContainer, completed: (PostDataContainer) -> Void) {

		self._post(container: container, capturedGistImage: nil, completed: completed)
	}
	
	func _post(container:PostDataContainer, capturedGistImage: NSImage?, completed: (PostDataContainer) -> Void) {
		
		let callNextStageRecursively = { [unowned self] (image: NSImage?) in
			
			container.proceedToNextStage()
			self._post(container: container, capturedGistImage: image, completed: completed)
		}
		
		let exitWithFailure = { (error: SNSController.PostError) in
			
			DebugTime.print("📮 Posted with failure (stage:\(container.stage), error:\(error)) ... #2.0.2")
			container.setError(error: error)
			completed(container)
		}
		
		do {
			
			switch container.stage {
				
			case .Initialized:
				
				callNextStageRecursively(capturedGistImage)
				
			case .PostToGists:
				
				DebugTime.print("📮 Try posting by Gists ... #2.2")
				
				try self.gists.post(container: container) { result in
					
					switch result {
						
					case .success:
						callNextStageRecursively(capturedGistImage)
						
					case .failure(let error):
						exitWithFailure(error)
					}
				}
				
			case .CaptureGists:
				
				let gist = container.gistsState.gist!
				DebugTime.print("📮 Capturing a gist (\(gist)) ... #2.2.1.1")
				
				let captureInfo = LinedCaptureInfo()
				let size = NSMakeSize(560.0, 560.0)
				
				NSApp.captureController.capture(url: gist.urls.htmlUrl.rawValue, clientSize: size, captureInfo: captureInfo) { image in
					
					DebugTime.print("📮 A gist captured ... #2.2.1.1.1")
					callNextStageRecursively(image)
				}
				
			case .PostToTwitter:
				
				callNextStageRecursively(capturedGistImage)
				
			case .PostToTwitterMedia:

				try self.twitter.postMedia(container: container, image: capturedGistImage!) { result in
					
					switch result {
						
					case .Success:
						callNextStageRecursively(capturedGistImage)
						
					case .Failure:
						exitWithFailure(container.error!)
					}
				}
				
			case .PostToTwitterStatus:
				
				DebugTime.print("📮 Try posting by Twitter ... #2.1")
				
				try self.twitter.post(container: container) { result in
					
					DebugTime.print("📮 Posted by Twitter (\(result)) ... #2.1.1")
					
					switch result {
						
					case .success:
						
						DebugTime.print("📮 Posted successfully (stage:\(container.stage)) ... #2.0.1")
						callNextStageRecursively(capturedGistImage)
						
					case .failure(let error):

						exitWithFailure(error)
					}
				}
				
			case .Posted:
				completed(container)
			}
		}
		catch let error as AuthenticationError {
			
			exitWithFailure(.Authentication(error))
		}
		catch let error as NSError {
			
			exitWithFailure(.Unexpected(error))
		}
	}
}

extension SNSController.AuthenticationError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .CredentialsNotVerified:
			return "Credentials not verified."
			
		case .NotAuthorized(let service):
			return "\(service) is not authorized."
			
		case .NotReady(let service, let message):
			return "\(service) is not ready. \(message)"
			
		case .InvalidAccount(let service, let reason):
			return "Invalid \(service) Account. \(reason)"
		}
	}
}

extension SNSController.PostError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case let .Unexpected(error):
			return "Unexpected error. \(error.localizedDescription)"
			
		case let .SystemError(message):
			return "System Error. \(message)"
			
		case let .Description(message):
			return "\(message)"

		case let .Authentication(error):
			return error.description
			
		case let .PostTextTooLong(limit):
			return "Post text over \(limit) characters."
			
		case let .FailedToUploadGistCapture(_, message):
			return "Failed to upload gist capture image. \(message)"
			
		case let .FailedToPostTweet(message):
			return "Failed to post tweet. \(message)"
		}
	}
}

extension SNSController.Service : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .Twitter:
			return "Twitter"
			
		case .GitHub:
			return "GitHub"
		}
	}
}
