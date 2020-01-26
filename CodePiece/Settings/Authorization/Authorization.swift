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
import Swifter

enum AuthorizationState {
	
	case Authorized
	case NotAuthorized
	
	var isValid:Bool {
		
		switch self {
			
		case .Authorized:
			return true
			
		case .NotAuthorized:
			return false
		}
	}
}

final class Authorization : AlertDisplayable {

	final class GitHub {
		
		var oauth2: OAuth2CodeGrant
		
		init() {
			
			let settings: OAuth2JSON = [
				
				"client_id" : APIKeys.GitHub.clientId,
				"client_secret" : APIKeys.GitHub.clientSecret,
				"authorize_uri" : "https://github.com/login/oauth/authorize",
				"token_uri" : "https://github.com/login/oauth/access_token",
				"scope" : "gist",
				"redirect_uris" : [ "\(GistScheme.scheme)://gist" ],
				"secret_in_body": true,
				"keychain" : false,
				"title" : "CodePiece",
				"verbose" : false
			]
			
			oauth2 = OAuth2CodeGrant(settings: settings)
		}
	}

	final class Twitter {

//		var swifter: Swifter
//		fileprivate(set) var pinRequesting: Bool

		init() {

//			swifter = Swifter(consumerKey: APIKeys.Twitter.consumerKey, consumerSecret: APIKeys.Twitter.consumerSecret)
		}
	}

	static var github = GitHub()
	static var twitter = Twitter()
	
	enum AuthorizationResult {

		case Created
		case Failed(Error)
//		case PinRequired
	}
}

// MARK: Twitter

//extension Authorization {
//
//	static var isTwitterPinRequesting: Bool {
//
//		return twitter.pinRequesting
//	}
//}

extension Authorization.AuthorizationResult {

	enum Error : Swift.Error {

		case twitterError(STTwitterTwitterErrorCode)
		case message(String)
	}
}

extension Authorization.AuthorizationResult.Error {

	init(_ error: NSError) {

		switch error.domain {

		case kSTTwitterTwitterErrorDomain:
			self = .twitterError(STTwitterTwitterErrorCode(rawValue: error.code)!)

		default:
			self = .message(error.localizedDescription)
		}
	}
}

extension Authorization.AuthorizationResult.Error : CustomStringConvertible {

	var description: String {

		switch self {

		case .twitterError(let code):
			return code.description

		case .message(let message):
			return message
		}
	}
}

// MARK: GitHub

extension Authorization {

	static func resetAuthorizationOfGitHub(id:ID, completion: @escaping (Result<Void, SessionTaskError>)->Void) {
		
		guard let authorization = NSApp.settings.account.authorization else {

			self.showWarningAlert(withTitle: "Failed to reset authorization", message: "Could't get the current authentication information. Reset authentication information which saved in this app.")
			
			NSApp.settings.resetGitHubAccount(saveFinally: true)
			GitHubAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()

			return
		}
		
		let request = GitHubAPI.OAuthAuthorizations.DeleteAuthorization(authorization: authorization, id:id)
		
		GitHubAPI.send(request) { response in
			
			defer {
				
				GitHubAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
			}

			switch response {
				
			case .success:
				
				// Token では削除できないようなので、403 で失敗しても認証情報を削除するだけにしています。
				NSApp.settings.resetGitHubAccount(saveFinally: true)
				completion(response)
				
			case .failure(_):

				NSApp.settings.resetGitHubAccount(saveFinally: true)
				completion(response)
			}
		}
	}
	
	private static func _githubAuthorizationCreateSuccessfully(user: Gist.User, authorization:GitHubAuthorization, completion:(AuthorizationResult)->Void) {
		
		let username = user.login
		let id = user.id
		
		defer {
			
			GitHubAuthorizationStateDidChangeNotification(isValid: true, username: username).post()
		}
		
		NSApp.settings.replaceGitHubAccount(username: username, id: id, authorization: authorization, saveFinally: true)
		
		completion(.Created)
	}
	
	private static func _githubAuthorizationFailed(error: AuthorizationResult.Error, completion:(AuthorizationResult)->Void) {
		
		NSApp.settings.resetGitHubAccount(saveFinally: true)
		completion(.Failed(error))
	}

//	static func authorizationWithTwitter(pin: String, completion:(AuthorizationResult)->Void) {
//
//		let oauth = self.twitter.oauth
//
//		let successHandler = { (token: String!, tokenSecret: String!, userId: String!, screenName: String!) in
//
//			NSLog("Twitter OAuth authentication did end successfully.")
//			DebugTime.print(" with: \(token), \(tokenSecret), \(userId), \(screenName)")
//
//			let account = TwitterController.Account(token: token, tokenSecret: tokenSecret, screenName: screenName)
//
//			TwitterAccountSelectorController.TwitterAccountSelectorDidChangeNotification(account: account).post()
//
//			twitter.pinRequesting = false
//			_twitterAuthorizationCreateSuccessfully(completion: completion)
//		}
//
//		let errorHandler = { (error: NSError!) in
//
//			print("Twitter authorization went wrong: \(error).")
//
//			_twitterAuthorizationFailed(error: .message("Check entered PIN code and try again."), completion: completion)
//		}
//
//		oauth.postAccessTokenRequestWithPIN(pin, successBlock: successHandler, errorBlock: errorHandler)
//	}
	
	static func authorizationWithTwitter(completion: @escaping (AuthorizationResult) -> Void) {

		let callback = ""
		
		func successHandler(accessToken: Credential.OAuthAccessToken) {

			let account = TwitterController.Account(token: accessToken.key, tokenSecret: accessToken.secret, screenName: accessToken.screenName!)
		
			DebugTime.print("📮 Passed verify-credentials #9")

			TwitterAccountSelectorController.TwitterAccountSelectorDidChangeNotification(account: account).post()
			Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: true, username: accessToken.screenName).post()

			
//			twitter.pinRequesting = false
			completion(.Created)
		}
		
		func errorHandler(error: Error) {

//			twitter.pinRequesting = false

			print("Twitter authorization went wrong: \(error).")
			completion(.Failed(.message(error.localizedDescription)))
		}

		NSApp.twitterController.authorize { result in
			
			switch result {
				
			case .success(let (.some(accessToken), name, id, response)):
				DebugTime.print(" with: \(accessToken), \(id), \(name), \(response)")
				successHandler(accessToken: accessToken)

			case .success(let (.none, name, id, response)):
				DebugTime.print(" Failed to get an AccessToken for: \(id), \(name), \(response)")
				errorHandler(error: AuthorizationResult.Error.message("Failed to get an Access Token for \(name)"))

			case .failure(let error):
				errorHandler(error: error)
			}
		}
	}
	
	static func authorizationWithGitHub(completion: @escaping (AuthorizationResult) -> Void) {
		
		let oauth2 = self.github.oauth2
		
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

				_githubAuthorizationFailed(error: AuthorizationResult.Error.message("Failed to get access token by GitHub."), completion: completion)
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
