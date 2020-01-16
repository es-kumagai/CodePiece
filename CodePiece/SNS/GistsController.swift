//
//  GistsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGists
import ESTwitter
import Result

final class GistsController : PostController, AlertDisplayable {

	let filename = "CodePiece"

	typealias PostResult = Result<PostDataContainer, SNSController.PostError>
	
	var canPost:Bool {
	
		return NSApp.settings.account.authorizationState.isValid
	}
	
	func post(container:PostDataContainer, completed:(PostResult)->Void) throws {

		guard let authorization = NSApp.settings.account.authorization else {
			
			throw SNSController.AuthenticationError.NotAuthorized(service: .GitHub)
		}

		let filename = container.filenameForGists
		let description = container.descriptionForGists()
		let publicGist = container.data.usePublicGists

		let file = GistFile(name: filename, content: container.data.code!)

		let request = GitHubAPI.Gists.CreateGist(authorization: authorization, files: [file], description: description, publicGist: publicGist)
		
		NSLog("Public=\(publicGist), File=\(filename), description=\(description)")
		NSLog("Try to send request: base url = \(request.baseURL), path = \(request.path).")
		
		GitHubAPI.sendRequest(request) { response in
			
			switch response {
				
			case .Success(let created):
				
				let gist = created.gist
				
				container.postedToGist(gist)
				
				NSLog("A Gist posted successfully. \(gist)")
				completed(PostResult(value: container))
				
			case .Failure(let error):

				completed(PostResult(error: .Description("Failed to post a gist. \(error)")))
			}
		}
	}
}
