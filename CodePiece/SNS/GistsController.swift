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

@objcMembers
@MainActor
final class GistsController : NSObject, AlertDisplayable {

	let filename = "CodePiece"

	var canPost: Bool {
	
		NSApp.settings.account.authorizationState.isValid
	}
	
	func post(container: PostDataContainer) async throws {

		guard let authorization = NSApp.settings.account.authorization else {
			
			throw SNSController.AuthenticationError.notAuthorized(service: .gist)
		}

		async let filename = container.filenameForGists
		async let description = container.descriptionForGists()
		async let publicGist = container.data.usePublicGists
		
		let file = await GistFile(name: filename, content: String(container.data.code))
		let request = await GitHubAPI.Gists.CreateGist(authorization: authorization, files: [file], description: description, publicGist: publicGist)
		
		await NSLog("Public=\(publicGist), File=\(filename), description=\(description)")

		NSLog("Try to send request: base url = \(request.baseURL), path = \(request.path).")
		
		do {
			let response = try await GitHubAPI.send(request)
			let gist = response.gist
			
			await container.postedToGist(gist: gist)
			
			NSLog("A Gist posted successfully. \(gist)")
		}
		catch {
			
			throw SNSController.PostError.description("Failed to post a gist. \(error)", state: .postGistDirectly)
		}
	}
}
