//
//  SNSController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter
import Result

protocol PostController {

	var canPost:Bool { get }
}

enum SNSControllerError : ErrorType, CustomStringConvertible {

	case CredentialsNotVerified
	case NotAuthorized
	case NotReady(String)
	
	var description:String {
		
		switch self {
			
		case .CredentialsNotVerified:
			return "Credentials not verified."
			
		case .NotAuthorized:
			return "Not authorized."
			
		case .NotReady(let message):
			return message
		}
	}
}

final class SNSController : PostController {

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

		self._post(container, capturedGistImage: nil, completed: completed)
	}
	
	func _post(container:PostDataContainer, capturedGistImage: NSImage?, completed: (PostDataContainer) -> Void) {
		
		let callNextStageRecursively = { [unowned self] (image: NSImage?) in
			
			container.proceedToNextStage()
			self._post(container, capturedGistImage: image, completed: completed)
		}
		
		let exitWithFailure = { (reason: String) in
			
			DebugTime.print("📮 Posted with failure (stage:\(container.stage), error:\(reason)) ... #2.0.2")
			container.setError(PostError(reason: reason))
			completed(container)
		}
		
		do {
			
			switch container.stage {
				
			case .Initialized:
				
				callNextStageRecursively(capturedGistImage)
				
			case .PostToGists:
				
				DebugTime.print("📮 Try posting by Gists ... #2.2")
				
				try self.gists.post(container) { result in
					
					switch result {
						
					case .Success:
						callNextStageRecursively(capturedGistImage)
						
					case .Failure(let error):
						exitWithFailure("\(error)")
					}
				}
				
			case .CaptureGists:
				
				let gist = container.gistsState.gist!
				DebugTime.print("📮 Capturing a gist (\(gist)) ... #2.2.1.1")
				
				let captureInfo = LinedCaptureInfo()
				let size = NSMakeSize(560.0, 560.0)
				
				NSApp.captureController.capture(gist.urls.htmlUrl.rawValue, clientSize: size, captureInfo: captureInfo) { image in
					
					DebugTime.print("📮 A gist captured ... #2.2.1.1.1")
					callNextStageRecursively(image)
				}
				
			case .PostToTwitter:
				
				callNextStageRecursively(capturedGistImage)
				
			case .PostToTwitterMedia:

				try self.twitter.postMedia(container, image: capturedGistImage!) { result in
					
					switch result {
						
					case .Success:
						callNextStageRecursively(capturedGistImage)
						
					case .Failure:
						exitWithFailure("\(container.error!.reason)")
					}
				}
				
			case .PostToTwitterStatus:
				
				DebugTime.print("📮 Try posting by Twitter ... #2.1")
				
				try self.twitter.post(container) { result in
					
					DebugTime.print("📮 Posted by Twitter (\(result)) ... #2.1.1")
					
					switch result {
						
					case .Success:
						
						DebugTime.print("📮 Posted successfully (stage:\(container.stage)) ... #2.0.1")
						callNextStageRecursively(capturedGistImage)
						
					case .Failure(let error):

						exitWithFailure("\(error)")
					}
				}
				
			case .Posted:
				completed(container)
			}
		}
		catch {
			
			exitWithFailure("\(error)")
		}
	}
}
