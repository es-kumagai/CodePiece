//
//  Authorization.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGists
import APIKit
import ESTwitter
import OAuth2
import CodePieceCore

enum AuthorizationState : Sendable {
	
	case authorized
	case notAuthorized
	
	var isValid: Bool {
		
		switch self {
			
		case .authorized:
			return true
			
		case .notAuthorized:
			return false
		}
	}
}

@MainActor
final class Authorization : AlertDisplayable {

	final class Gist {
		
		var oauth2: OAuth2CodeGrant
		
		init() {
			
			oauth2 = Self.makeNewCodeGrant()
		}
		
		func reset() {
			
			oauth2 = Self.makeNewCodeGrant()
		}
	}

	final class Twitter {

		init() {
		}
	}

	static var gist = Gist()
//	static var twitter = Twitter()
}

// MARK: Twitter

extension Authorization {

	enum AuthorizationError : Error {
	
		case message(String)
	}
}

extension Authorization.AuthorizationError {

	init(_ error: NSError) {

		switch error.domain {

		default:
			self = .message(error.localizedDescription)
		}
	}
}

extension Authorization.AuthorizationError : CustomStringConvertible {

	var description: String {

		switch self {

		case .message(let message):
			return message
		}
	}
}

// MARK: GitHub

extension Authorization {

	static func resetAuthorizationOfGist(id: ID) async throws {
		
		guard let authorization = NSApp.settings.account.authorization else {

			showWarningAlert(withTitle: "Failed to reset authorization", message: "Could't get the current authentication information. Reset authentication information which saved in this app.")
			
			NSApp.settings.resetGistAccount(saveFinally: true)
			GistAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()

			return
		}
		
		let request = GitHubAPI.OAuthAuthorizations.DeleteAuthorization(authorization: authorization, id:id)
		
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in

			GitHubAPI.send(request) { response in
				
				defer {
					
					GistAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
				}
				
				switch response {
					
				case .success:
					
					// Token では削除できないようなので、403 で失敗しても認証情報を削除するだけにしています。
					NSApp.settings.resetGistAccount(saveFinally: true)
					gist.reset()
					
					continuation.resume()
					
				case .failure(let error):
					
					NSApp.settings.resetGistAccount(saveFinally: true)
					gist.reset()

					continuation.resume(throwing: error)
				}
			}
		}
	}
		
	// FIXME: Gists の認証処理は GistController が担えば良さそうです。Twitter はそうしています。
	static func authorizationWithGist() async throws {
		
		let oauth2 = gist.oauth2
		
		NSLog("Trying authorization with GitHub OAuth.")
		
		oauth2.authConfig.authorizeEmbedded = false
		oauth2.authConfig.authorizeContext = NSApp.keyWindow
		
		let parameters: OAuth2JSON
		
		do {
			
			parameters = try await oauth2.authorize()
		}
		catch {

			print("GitHub authorization went wrong: \(error)")
			return
		}

		var scopeAndTokenFromParameters: (scope: String?, token: String?) {
			
			var scope: String?
			var accessToken: String?
			
			for (key, value) in parameters {
				
				switch key {
					
				case "access_token":
					accessToken = value as? String
					
				case "scope":
					scope = value as? String
					
				default:
					break
				}
			}
			
			return (scope, accessToken)
		}
		
		guard case let (scope?, accessToken?) = scopeAndTokenFromParameters else {
			
			NSApp.settings.resetGistAccount(saveFinally: true)
			gist.reset()
			
			throw AuthorizationError.message("Failed to get access token by GitHub. Please try again later")
		}
		
		NSLog("GitHub OAuth authentication did end successfully with scope=\(scope).")
		DebugTime.print(" with parameters: \(parameters)")
		
		let authorization = GitHubAuthorization.token(accessToken)
		let request = GitHubAPI.Users.GetAuthenticatedUser(authorization: authorization)
		
		do {
			
			let user = try await GitHubAPI.send(request)
			
			let username = user.login
			let id = user.id
			
			defer {
				
				GistAuthorizationStateDidChangeNotification(isValid: true, username: username).post()
			}
			
			NSApp.settings.replaceGistAccount(username: username, id: id, authorization: authorization, saveFinally: true)
		}
		catch {
			
			NSApp.settings.resetGistAccount(saveFinally: true)
			
			throw AuthorizationError.message("\(error)")
		}
	}
}

private extension Authorization.Gist {
	
	static func makeNewCodeGrant() -> OAuth2CodeGrant {
		
		return OAuth2CodeGrant(settings: settings)
	}
	
	static var settings: OAuth2JSON {
		
		guard let clientId = APIKeys.Gist.clientId, let clientSecret = APIKeys.Gist.clientSecret else {
			
			fatalError("You MUST specify id and key in `APIKeys.GitHub`.")
		}
		
		return [
			
			"client_id" : clientId,
			"client_secret" : clientSecret,
			"authorize_uri" : "https://github.com/login/oauth/authorize",
			"token_uri" : "https://github.com/login/oauth/access_token",
			"scope" : "gist",
			"redirect_uris" : [ "\(GistScheme.scheme)://gist" ],
			"secret_in_body": true,
			"keychain" : false,
			"title" : "CodePiece",
			"verbose" : false
		]
	}
}
