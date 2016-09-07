//
//  Authorization.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESGists
import APIKit
import STTwitter
import Result
import ESThread
import p2_OAuth2

// TODO: To build the project, you must create `CodePieceClientInfo` type. See also `HowToBuild.md`.

var ClientInfo:CodePieceClientInfo!

protocol GitHubClientInfoType {
	
	var GitHubClientID:String { get }
	var GitHubClientSecret:String { get }
}

protocol TwitterConsumerInfoType {
	
	var TwitterConsumerKey:String { get }
	var TwitterConsumerSecret:String { get }
}

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
		
		var oauth2:OAuth2CodeGrant
		
		init() {
			
			let settings:OAuth2JSON = [
				
				"client_id" : ClientInfo.GitHubClientID,
				"client_secret" : ClientInfo.GitHubClientSecret,
				"authorize_uri" : "https://github.com/login/oauth/authorize",
				"token_uri" : "https://github.com/login/oauth/access_token",
				"scope" : "gist",
				"redirect_uris" : [ "jp.ez-style.scheme.codepiece://oauth" ],
				"secret_in_body": true,
				"keychain" : false,
				"title" : "CodePiece",
				"verbose" : false
			]
			
			self.oauth2 = OAuth2CodeGrant(settings: settings)
		}
	}

	final class Twitter {
		
		var oauth: STTwitterOAuth
		
		init() {

			self.oauth = STTwitterOAuth(consumerName: nil, consumerKey: ClientInfo.TwitterConsumerKey, consumerSecret: ClientInfo.TwitterConsumerSecret)
		}
	}

	static var github = GitHub()
	static var twitter = Twitter()
	
	enum AuthorizationResult {

		case Created
		case Failed(String)
		case PinRequired
	}
}

// MARK: Twitter

extension Authorization {

}

// MARK: GitHub

extension Authorization {

	static func resetAuthorizationOfGitHub(id:ID, completion:(Result<Void,APIError>)->Void) {
		
		guard let authorization = NSApp.settings.account.authorization else {

			self.showWarningAlert("Failed to reset authorization", message: "Could't get the current authentication information. Reset authentication information which saved in this app.")
			
			NSApp.settings.resetGitHubAccount(saveFinally: true)
			GitHubAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()

			return
		}
		
		let request = GitHubAPI.OAuthAuthorizations.DeleteAuthorization(authorization: authorization, id:id)
		
		GitHubAPI.sendRequest(request) { response in
			
			defer {
				
				GitHubAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
			}

			switch response {
				
			case .Success:
				
				// Token では削除できないようなので、403 で失敗しても認証情報を削除するだけにしています。
				NSApp.settings.resetGitHubAccount(saveFinally: true)
				completion(response)
				
			case .Failure(_):

				NSApp.settings.resetGitHubAccount(saveFinally: true)
				completion(response)
			}
		}
	}
	
	private static func _twitterAuthorizationCreateSuccessfully(completion:(AuthorizationResult)->Void) {
		
		completion(.Created)
	}
	
	private static func _twitterAuthorizationFailed(error:String, completion:(AuthorizationResult)->Void) {
		
		completion(.Failed(error))
	}
	
	private static func _githubAuthorizationCreateSuccessfully(user user:GistUser, authorization:GitHubAuthorization, completion:(AuthorizationResult)->Void) {
		
		let username = user.login
		let id = user.id
		
		defer {
			
			GitHubAuthorizationStateDidChangeNotification(isValid: true, username: username).post()
		}
		
		NSApp.settings.replaceGitHubAccount(username, id: id, authorization: authorization, saveFinally: true)
		
		completion(.Created)
	}
	
	private static func _githubAuthorizationFailed(error:String, completion:(AuthorizationResult)->Void) {
		
		NSApp.settings.resetGitHubAccount(saveFinally: true)
		completion(.Failed(error))
	}

	static func authorizationWithTwitter(pin pin: String, completion:(AuthorizationResult)->Void) {
		
		let oauth = self.twitter.oauth
		
		let successHandler = { (token: String!, tokenSecret: String!, userId: String!, screenName: String!) in
			
			NSLog("Twitter OAuth authentication did end successfully.")
			DebugTime.print(" with: \(token), \(tokenSecret), \(userId), \(screenName)")
			
			let account = TwitterController.Account(token: token, tokenSecret: tokenSecret, screenName: screenName)
			
			TwitterAccountSelectorController.TwitterAccountSelectorDidChangeNotification(account: account).post()
			
			_twitterAuthorizationCreateSuccessfully(completion)
		}
		
		let errorHandler = { (error: NSError!) in
			
			print("Twitter authorization went wrong: \(error).")
			
			_twitterAuthorizationFailed("Check entered PIN code and try again.", completion: completion)
		}
		
		oauth.postAccessTokenRequestWithPIN(pin, successBlock: successHandler, errorBlock: errorHandler)
	}
	
	static func authorizationWithTwitter(completion:(AuthorizationResult)->Void) {

		let oauth = self.twitter.oauth
		let callback = ""
		
		let successHandler = { (oauthUrl: NSURL!, oauthToken: String!) in

			NSLog("Twitter OAuth require PIN code.")
			DebugTime.print(" with url: \(oauthUrl), string: \(oauthToken)")
			
			NSWorkspace.sharedWorkspace().openURL(oauthUrl)
			
			completion(.PinRequired)
		}
		
		let errorHandler = { (error: NSError!) in

			print("Twitter authorization went wrong: \(error).")
			_twitterAuthorizationFailed("\(error)", completion: completion)
		}
		
		oauth.postTokenRequest(successHandler, oauthCallback: callback, errorBlock: errorHandler)		
	}
	
	static func authorizationWithGitHub(completion:(AuthorizationResult)->Void) {
		
		let oauth2 = self.github.oauth2
		
		oauth2.onAuthorize = { parameters in
			
			guard case let (scope?, token?) = (parameters["scope"] as? String, parameters["access_token"] as? String) else {

				_githubAuthorizationFailed("Failed to get access token by GitHub.", completion: completion)
				return
			}
			
			NSLog("GitHub OAuth authentication did end successfully with scope=\(scope).")
			DebugTime.print(" with parameters: \(parameters)")
			
			let authorization = GitHubAuthorization.Token(token)
			let request = GitHubAPI.Users.GetAuthenticatedUser(authorization: authorization)
			
			GitHubAPI.sendRequest(request) { response in
				
				switch response {
					
				case .Success(let user):
					_githubAuthorizationCreateSuccessfully(user: user, authorization: authorization, completion: completion)
					
				case .Failure(let error):
					_githubAuthorizationFailed(String(error), completion: completion)
				}
			}
		}
		
		oauth2.onFailure = { error in
			
			print("GitHub authorization went wrong" + (error.map { ": \($0)." } ?? "."))
		}
		
		NSLog("Trying authorization with GitHub OAuth.")
		try! oauth2.openAuthorizeURLInBrowser()
	}
}
