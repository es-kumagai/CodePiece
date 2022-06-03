//
//  SNSController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

@preconcurrency import class AppKit.NSImage
import ESGists
import ESTwitter
import CodePieceCore

@objcMembers
@MainActor
final class SNSController : NSObject {
	
	let gists: GistsController
	let twitter: TwitterController
	
	weak var captureController: WebCaptureController!
	
	init(captureController: WebCaptureController) {
		
		self.gists = GistsController()
		self.twitter = TwitterController()
		self.captureController = captureController
	}
	
	dynamic var canPost: Bool {
		
		gists.canPost && twitter.canPost
	}
	
	@available(*, message: "Concurrency に対応したら、エラーを状態としてもたなくても throwing で済むかもしれません。")
	func post(container: PostDataContainer) async {
		
		await _post(container: container, capturedGistImage: nil)
	}
}

private extension SNSController {

	func _post(container: PostDataContainer, capturedGistImage: NSImage?) async {
		
		@Sendable func callNextStageRecursively(image: NSImage?) async {
			
			await container.proceedToNextStage()
			await _post(container: container, capturedGistImage: image)
		}
		
		do {
			
			switch await container.stage {
				
			case .initialized:
				
				await container.clearErrors()
				await callNextStageRecursively(image: capturedGistImage)
				
			case .postToGists:
				
				DebugTime.print("📮 Try posting by Gists ... #2.2")
				
				try await gists.post(container: container)
				await callNextStageRecursively(image: capturedGistImage)
				
			case .captureGists:
				
				let gist = await container.gistsState.gist!
				DebugTime.print("📮 Capturing a gist (\(gist)) ... #2.2.1.1")
				
				let captureInfo = CaptureInfo.twitterGeneric
				let image = try await captureController.capture(url: gist.urls.htmlUrl.rawValue, of: container.filenameForGists, captureInfo: captureInfo)
				
				DebugTime.print("📮 A gist captured ... #2.2.1.1.1")
				await callNextStageRecursively(image: image)

			case .postProcessToTwitter:
				await callNextStageRecursively(image: capturedGistImage)
				
			case .postToTwitterMedia:

				if let image = capturedGistImage {
					
					await twitter.post(image: image, container: container)
					await callNextStageRecursively(image: capturedGistImage)
				}
				else {
					
					await container.setError(.failedToUploadMedia(reason: "Failed to take Gist capture image.", state: .occurred(on: .postToTwitterMedia)))
					await callNextStageRecursively(image: capturedGistImage)
				}
				
			case .postToTwitterStatus:
				
				DebugTime.print("📮 Try posting by Twitter ... #2.1")
				try await twitter.post(statusUsing: container)
					
				await DebugTime.printAsync("📮 Posted successfully (stage:\(await container.stage)) ... #2.0.1")
				await callNextStageRecursively(image: capturedGistImage)
				
			case .posted:
				break
			}
		}
		catch {
			
			var throwingError: SNSController.PostError
			
			switch error {
				
			case let error as AuthenticationError:
				throwingError = .authentication(error, state: .occurred(on: .postToGists))
				
			case let error as SNSController.PostError:
				throwingError = error
				
			case let error as NSError:
				throwingError = .unexpected(error, state: .occurred(on: .postToGists))
			}
			
			await DebugTime.printAsync("📮 Posted with failure (stage:\(await container.stage), error:\(throwingError)) ... #2.0.2")
			await container.setError(throwingError)
		}
	}
}
