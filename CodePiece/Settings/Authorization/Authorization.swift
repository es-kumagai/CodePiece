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

enum AuthorizationState {
	
	case authorized
	case notAuthorized
	
	var isValid:Bool {
		
		switch self {
			
		case .authorized:
			return true
			
		case .notAuthorized:
			return false
		}
	}
}

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
	
	enum AuthorizationResult {

		case Created
		case Failed(Error)
	}
}

// MARK: Twitter

extension Authorization.AuthorizationResult {

	enum Error : Swift.Error {

		case message(String)
	}
}

extension Authorization.AuthorizationResult.Error {

	init(_ error: NSError) {

		switch error.domain {

		default:
			self = .message(error.localizedDescription)
		}
	}
}

extension Authorization.AuthorizationResult.Error : CustomStringConvertible {

	var description: String {

		switch self {

		case .message(let message):
			return message
		}
	}
}

// MARK: GitHub

extension Authorization {

	static func resetAuthorizationOfGist(id: ID, completion: @escaping (Result<Void, SessionTaskError>)->Void) {
		
		guard let authorization = NSApp.settings.account.authorization else {

			showWarningAlert(withTitle: "Failed to reset authorization", message: "Could't get the current authentication information. Reset authentication information which saved in this app.")
			
			NSApp.settings.resetGistAccount(saveFinally: true)
			GistAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()

			return
		}
		
		let request = GitHubAPI.OAuthAuthorizations.DeleteAuthorization(authorization: authorization, id:id)
		
		GitHubAPI.send(request) { response in
			
			defer {
				
				GistAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
			}

			switch response {
				
			case .success:
				
				// Token では削除できないようなので、403 で失敗しても認証情報を削除するだけにしています。
				NSApp.settings.resetGistAccount(saveFinally: true)
				gist.reset()
				
				completion(response)
				
			case .failure(_):

				NSApp.settings.resetGistAccount(saveFinally: true)
				gist.reset()

				completion(response)
			}
		}
	}
	
	private static func _githubAuthorizationCreateSuccessfully(user: ESGists.Gist.User, authorization:GitHubAuthorization, completion:(AuthorizationResult)->Void) {
		
		let username = user.login
		let id = user.id
		
		defer {
			
			GistAuthorizationStateDidChangeNotification(isValid: true, username: username).post()
		}
		
		NSApp.settings.replaceGistAccount(username: username, id: id, authorization: authorization, saveFinally: true)
		
		completion(.Created)
	}
	
	private static func _githubAuthorizationFailed(error: AuthorizationResult.Error, completion:(AuthorizationResult)->Void) {
		
		NSApp.settings.resetGistAccount(saveFinally: true)
		completion(.Failed(error))
	}
	
	// FIXME: Gists の認証処理は GistController が担えば良さそうです。Twitter はそうしています。
	static func authorizationWithGist(completion: @escaping (AuthorizationResult) -> Void) {
		
		let oauth2 = gist.oauth2
		
		func onAuthorize(_ parameters: OAuth2JSON) {

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

				_githubAuthorizationFailed(error: AuthorizationResult.Error.message("Failed to get access token by GitHub. Please try again later"), completion: completion)

				gist.reset()
				return
			}

			NSLog("GitHub OAuth authentication did end successfully with scope=\(scope).")
			DebugTime.print(" with parameters: \(parameters)")

			let authorization = GitHubAuthorization.token(accessToken)
			let request = GitHubAPI.Users.GetAuthenticatedUser(authorization: authorization)

			GitHubAPI.send(request) { response in

				switch response {

				case .success(let user):
					_githubAuthorizationCreateSuccessfully(user: user, authorization: authorization, completion: completion)

				case .failure(let error):
					_githubAuthorizationFailed(error: AuthorizationResult.Error.message("\(error)"), completion: completion)
				}
			}
		}

		func onFailure(_ error: OAuth2Error?) {

			print("GitHub authorization went wrong" + (error.map { ": \($0)." } ?? "."))
		}

		NSLog("Trying authorization with GitHub OAuth.")
		
		oauth2.authConfig.authorizeEmbedded = false
		oauth2.authConfig.authorizeContext = NSApp.keyWindow
		
		oauth2.authorize { json, error in
			
			guard let json = json else {
				
				onFailure(error)
				return
			}
			
			onAuthorize(json)
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
