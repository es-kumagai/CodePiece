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
	
	var gists: GistsController
	var twitter: TwitterController
	
	typealias PostResult = Result<PostDataContainer, PostError>
	
	init() {
		
		gists = GistsController()
		twitter = TwitterController()
	}
	
	var canPost:Bool {
		
		return gists.canPost && twitter.canPost
	}
	
	func post(container: PostDataContainer, completed: @escaping (PostDataContainer) -> Void) {
		
		self._post(container: container, capturedGistImage: nil, completed: completed)
	}
	
	func _post(container: PostDataContainer, capturedGistImage: NSImage?, completed: @escaping (PostDataContainer) -> Void) {
		
		let callNextStageRecursively = { [unowned self] (image: NSImage?) in
			
			container.proceedToNextStage()
			self._post(container: container, capturedGistImage: image, completed: completed)
		}
		
		let exitWithFailure = { (error: SNSController.PostError) in
			
			DebugTime.print("📮 Posted with failure (stage:\(container.stage), error:\(error)) ... #2.0.2")
			container.setError(error)
			completed(container)
		}
		
		switch container.stage {
			
		case .Initialized:
			
			container.clearErrors()
			callNextStageRecursively(capturedGistImage)
			
		case .PostToGists:
			
			DebugTime.print("📮 Try posting by Gists ... #2.2")
			
			do {
				try gists.post(container: container) { result in
					
					switch result {
						
					case .success:
						callNextStageRecursively(capturedGistImage)
						
					case .failure(let error):
						exitWithFailure(error)
					}
				}
			}
			catch let error as AuthenticationError {
				
				exitWithFailure(.authentication(error, state: .occurred(on: .PostToGists)))
			}
			catch let error as NSError {
				
				exitWithFailure(.unexpected(error, state: .occurred(on: .PostToGists)))
			}
			
		case .CaptureGists:
			
			let gist = container.gistsState.gist!
			DebugTime.print("📮 Capturing a gist (\(gist)) ... #2.2.1.1")
			
			let captureInfo = LinedCaptureInfo()
			let size = NSMakeSize(560.0, 560.0)
			
			NSApp.captureController.capture(url: gist.urls.htmlUrl.rawValue, of: container.filenameForGists, clientSize: size, captureInfo: captureInfo) { image in
				
				DebugTime.print("📮 A gist captured ... #2.2.1.1.1")
				callNextStageRecursively(image)
			}
			
		case .PostProcessToTwitter:
			
			callNextStageRecursively(capturedGistImage)
			
		case .PostToTwitterMedia:
			
			if let image = capturedGistImage {
				
				twitter.post(image: image, container: container) { result in
					
					switch result {
						
					case .success:
						callNextStageRecursively(capturedGistImage)
						
					case .failure(let error):
						exitWithFailure(error)
					}
				}
			}
			else {
				
				container.setError(.failedToUploadMedia(reason: "Failed to take Gist capture image.", state: .occurred(on: .PostToTwitterMedia)))
				callNextStageRecursively(capturedGistImage)
			}
			
		case .PostToTwitterStatus:
			
			DebugTime.print("📮 Try posting by Twitter ... #2.1")
			
			twitter.post(statusUsing: container) { result in
				
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
}

//extension SNSController.PostError : CustomStringConvertible {
//
//	var description: String {
//
//		switch self {
//
//		case let .Unexpected(error):
//			return "Unexpected error. \(error.localizedDescription)"
//
//		case let .SystemError(message):
//			return "System Error. \(message)"
//
//		case let .Description(message):
//			return "\(message)"
//
//		case let .Authentication(error):
//			return error.description
//
////		case let .PostTextTooLong(limit):
////			return "Post text over \(limit) characters."
//
//		case let .FailedToUploadMedia(message):
//			return "Failed to upload gist capture image. \(message)"
//
//		case let .twitterError(message):
//			return "Failed to post tweet. \(message)"
//		}
//	}
//}

