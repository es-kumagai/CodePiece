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
var TwitterClientInfo:TwitterClientInfoType!

protocol GitHubClientInfoType {
	
	var id:String { get }
	var secret:String { get }
}

protocol TwitterClientInfoType {
	
	var consumerKey:String { get }
	var consumerSecret:String { get }
}

enum AuthorizationState {
	
	case Authorized
	case AuthorizedWithNoToken
	case NotAuthorized
	
	var isValid:Bool {
		
		switch self {
			
		case .Authorized:
			return true
			
		case .AuthorizedWithNoToken, .NotAuthorized:
			return false
		}
	}
}

struct Authorization : AlertDisplayable {

	enum GitHubAuthorizationResult {

		case Created
		case AlreadyCreated
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
			
			settings.resetGitHubAccount()
			AuthorizationStateDidChangeNotification().post()

			return
		}
		
		let request = GitHubAPI.OAuthAuthorizations.DeleteAuthorization(authorization: authorization, id:id)
		
		GitHubAPI.sendRequest(request) { response in
			
			defer {
				
				AuthorizationStateDidChangeNotification().post()
			}

			switch response {
				
			case .Success:
				
				// Token では削除できないようなので、403 で失敗しても認証情報を削除するだけにしています。
				settings.resetGitHubAccount()
				completion(response)
				
			case .Failure(_):

				settings.resetGitHubAccount()
				completion(response)
			}
		}
	}
	
	static func authorizationWithGitHub(username:String, password:String, completion:(GitHubAuthorizationResult)->Void) {
		
		let client = GitHubClientInfo
		let scope = Scope.Gist
		
		let authorization = ESGists.GitHubAuthorization(id: username, password: password)
		
		NSLog("Try to get or create new authorization for '\(username)' by client '\(client.id)'.")

		// 認証処理は、認証情報が既に記録されているかで実行タイミングが変わるため、融通がきくようにクロージャーで用意しています。
		let authorize = { () -> Void in
			
			let request = GitHubAPI.OAuthAuthorizations.GetOrCreateNewAuthorization(authorization: authorization, clientId: client.id, clientSecret: client.secret, options: [ .Scopes([scope]) ])
			
			GitHubAPI.sendRequest(request) { response in
				
				switch response {
					
				case .Success(let authorized):
					self.authorizationSucceeded(authorized, username: username, password: password, completion: completion)
					
				case .Failure(let error):
					completion(.Failed(String(error)))
				}
			}
		}
		
		// アプリに ID 情報が記録されていた場合は、それを削除してから認証を行います。
		if let id = settings.account.id {
			
			let request = GitHubAPI.OAuthAuthorizations.DeleteAuthorization(authorization: authorization, id:id)
			
			GitHubAPI.sendRequest(request) { response in
				
				settings.resetGitHubAccount()
				
				// 削除処理の成功の可否に関わらず、処理後に認証を実行します。
				authorize()
				
				// 削除処理の失敗はログに記録しておきます。
				if case .Failure(let error) = response {
					
					// 認証に失敗していた場合の後始末です。
					NSLog("Failed to reset authorization. Could't reset the current authentication information. Reset authentication information which saved in this app force. (\(error))")
				}
			}
		}
		else {
			
			authorize()
		}

	}
	
	private static func authorizationSucceeded(response:AuthorizationResponseWithStatus, username:String, password:String, completion:(GitHubAuthorizationResult)->Void) {
		
		switch response.status {
			
		case .Created:
			self.authorizationCreateSuccessfully(response.authorization, username: username, completion: completion)
			
		case .AlreadyExists:
			self.authorizationAlreadyCreated(response.authorization, username: username, password: password, completion: completion)
		}
	}
	
	private static func authorizationCreateSuccessfully(response:AuthorizationResponse, username:String, completion:(GitHubAuthorizationResult)->Void) {
		
		defer {
			
			AuthorizationStateDidChangeNotification().post()
		}
		
		settings.replaceGitHubAccount(username, authorization: response)

		completion(.Created)
	}
	
	private static func authorizationAlreadyCreated(response:AuthorizationResponse, username:String, password:String, completion:(GitHubAuthorizationResult)->Void) {
		
		defer {
			
			AuthorizationStateDidChangeNotification().post()
		}
		
		// アプリが認証後の ID を保持していない場合は、再認証を試みます。（ID 情報があれば削除されるため）
		let retryAuthorization = settings.account.id == nil
		
		settings.updateGitHubAccount(username, authorization: response)
		
		if retryAuthorization {

			NSLog("Retry authorization for GitHub.")
			self.authorizationWithGitHub(username, password: password, completion: completion)
		}
		else {

			completion(.AlreadyCreated)
		}
	}
}
