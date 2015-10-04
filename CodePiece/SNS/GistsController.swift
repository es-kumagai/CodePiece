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

	typealias PostResult = Result<ESGists.Gist,NSError>
	
	var canPost:Bool {
	
		return settings.account.authorizationState.isValid
	}
	
	func post(content:String, language:ESGists.Language, description:String, hashtag:ESTwitter.Hashtag, completed:(PostResult)->Void) throws {

		guard let authorization = settings.account.authorization else {
			
			throw SNSControllerError.NotAuthorized
		}

		let filename = self.filename.appendStringIfNotEmpty(language.extname, separator: ".")
		let description = DescriptionGenerator(description, language: nil, hashtag: hashtag, appendAppTag: true)

		#if DEBUG
			let publicGist = false
		#else
			let publicGist = true
		#endif
		
		let file = GistFile(name: filename, content: content)

		let request = GitHubAPI.Gists.CreateGist(authorization: authorization, files: [file], description: description, publicGist: publicGist)
		
		NSLog("Public=\(publicGist), File=\(filename), description=\(description)")
		NSLog("Try to send request: base url = \(request.baseURL), path = \(request.path).")
		
		GitHubAPI.sendRequest(request) { response in
			
			switch response {
				
			case .Success(let created):
				
				let gist = created.gist
				
				NSLog("A Gist posted successfully. \(gist)")
				completed(PostResult(value: gist))
				
			case .Failure(let error):
				
				completed(PostResult(error: NSError(domain: "Failed to post a gist. \(error)", code: -1, userInfo: nil)))
			}
		}
	}
}
