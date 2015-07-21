//
//  GistsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGist

final class GistsController : AlertDisplayable {

	static let filename = "CodePiece"
	
	static func post(content:String, language:ESGist.Language, description:String, hashtag:String, completed:(ESGist.Gist?)->Void) {

		guard let authorization = settings.account.authorization else {
			
			self.showWarningAlert("Cannot post", message: "The authentication token is not correct. Please re-authentication.")
			completed(nil)
			
			return
		}

		let filename = self.filename.appendStringIfNotEmpty(language.extname, separator: ".")
		let description = DescriptionGenerator(description, language: nil, hashtag: hashtag)
		let publicGist = true
		
		let file = GistFile(name: filename, content: content)

		let request = GitHubAPI.Gists.CreateGist(authorization: authorization, files: [file], description: description, publicGist: publicGist)
		
		NSLog("Public=\(publicGist), File=\(filename), description=\(description)")
		NSLog("Try to send request: base url = \(request.baseURL), path = \(request.path).")
		
		GitHubAPI.sendRequest(request) { response in
			
			switch response {
				
			case .Success(let created):
				
				let gist = created.gist
				
				NSLog("A Gist posted successfully. \(gist)")
				completed(gist)
				
			case .Failure(let error):
				
				self.showErrorAlert("Failed to post a gist", message: String(error))
				completed(nil)
			}
		}
	}
}
