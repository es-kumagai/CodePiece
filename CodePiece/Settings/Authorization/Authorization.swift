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

// このプロトコルに準拠したクライアント情報をプロジェクトに実装し、
// AppDelegate 等から GitHubClientInfo 変数にそのインスタンスを設定してください。
//
// e.g.
//
//	struct CodePieceClientInfo : GitHubClientInfoType {
//
//		let id = "xxxxxxxx"
//		let secret = "xxxxxxxx"
//	}

var GitHubClientInfo:GitHubClientInfoType!

protocol GitHubClientInfoType {
	
	var id:String { get }
	var secret:String { get }
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
				
				"client_id" : GitHubClientInfo.id,
				"client_secret" : GitHubClientInfo.secret,
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
	
	static var github = GitHub()
	
	enum GitHubAuthorizationResult {

		case Created
		case Failed(String)
	}
}

// MARK: Twitter

extension Authorization {

}

// MARK: GitHub

extension Authorization {

	static func resetAuthorizationOfGitHub(id:ID, completion:(Result<Void,APIError>)->Void) {
		
		guard let authorization = settings.account.authorization else {

			self.showWarningAlert("Failed to reset authorization", message: "Could't get the current authentication information. Reset authentication information which saved in this app.")
			
			settings.resetGitHubAccount(saveFinally: true)
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
				settings.resetGitHubAccount(saveFinally: true)
				completion(response)
				
			case .Failure(_):

				settings.resetGitHubAccount(saveFinally: true)
				completion(response)
			}
		}
	}
	
	private static func _authorizationCreateSuccessfully(user user:GistUser, authorization:GitHubAuthorization, completion:(GitHubAuthorizationResult)->Void) {
		
		let username = user.login
		let id = user.id
		
		defer {
			
			GitHubAuthorizationStateDidChangeNotification(isValid: true, username: username).post()
		}
		
		settings.replaceGitHubAccount(username, id: id, authorization: authorization, saveFinally: true)
		
		completion(.Created)
	}
	
	private static func _authorizationFailed(error:String, completion:(GitHubAuthorizationResult)->Void) {
		
		settings.resetGitHubAccount(saveFinally: true)
		completion(.Failed(error))
	}
	
	static func authorizationWithGitHub(completion:(GitHubAuthorizationResult)->Void) {
		
		let oauth2 = self.github.oauth2
		
		oauth2.onAuthorize = { parameters in
			
			guard case let (scope?, token?) = (parameters["scope"] as? String, parameters["access_token"] as? String) else {

				_authorizationFailed("Failed to get access token.", completion: completion)
				return
			}
			
			NSLog("OAuth authentication did end successfully with scope=\(scope).")
			DebugTime.print(" with parameters: \(parameters)")
			
			let authorization = GitHubAuthorization.Token(token)
			let request = GitHubAPI.Users.GetAuthenticatedUser(authorization: authorization)
			
			GitHubAPI.sendRequest(request) { response in
				
				switch response {
					
				case .Success(let user):
					_authorizationCreateSuccessfully(user: user, authorization: authorization, completion: completion)
					
				case .Failure(let error):
					_authorizationFailed(String(error), completion: completion)
				}
			}
		}
		
		oauth2.onFailure = { error in
			
			print("Authorization went wrong: \(error?.localizedDescription)")
		}
		
		NSLog("Trying authorization with GitHub OAuth.")
		oauth2.openAuthorizeURLInBrowser()
	}
}
