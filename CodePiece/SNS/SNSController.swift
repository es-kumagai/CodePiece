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
import CodePieceCore

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
		
		_post(container: container, capturedGistImage: nil, completed: completed)
	}
	
	func _post(container: PostDataContainer, capturedGistImage: NSImage?, completed: @escaping (PostDataContainer) -> Void) {
		
		let callNextStageRecursively = { [unowned self] (image: NSImage?) in
			
			container.proceedToNextStage()
			_post(container: container, capturedGistImage: image, completed: completed)
		}
		
		let exitWithFailure = { (error: SNSController.PostError) in
			
			DebugTime.print("📮 Posted with failure (stage:\(container.stage), error:\(error)) ... #2.0.2")
			container.setError(error)
			completed(container)
		}
		
		switch container.stage {
			
		case .initialized:
			
			container.clearErrors()
			callNextStageRecursively(capturedGistImage)
			
		case .postToGists:
			
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
				
				exitWithFailure(.authentication(error, state: .occurred(on: .postToGists)))
			}
			catch let error as NSError {
				
				exitWithFailure(.unexpected(error, state: .occurred(on: .postToGists)))
			}
			
		case .captureGists:
			
			let gist = container.gistsState.gist!
			DebugTime.print("📮 Capturing a gist (\(gist)) ... #2.2.1.1")
			
			let captureInfo = CaptureInfo.lined
			
			NSApp.captureController.capture(url: gist.urls.htmlUrl.rawValue, of: container.filenameForGists, captureInfo: captureInfo) { image in
				
				DebugTime.print("📮 A gist captured ... #2.2.1.1.1")
				callNextStageRecursively(image)
			}
			
		case .postProcessToTwitter:
			
			callNextStageRecursively(capturedGistImage)
			
		case .postToTwitterMedia:
			
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
				
				container.setError(.failedToUploadMedia(reason: "Failed to take Gist capture image.", state: .occurred(on: .postToTwitterMedia)))
				callNextStageRecursively(capturedGistImage)
			}
			
		case .postToTwitterStatus:
			
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
			
		case .posted:
			
			completed(container)
		}
	}
}
