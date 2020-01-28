//
//  Settings.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESGists
import ESTwitter


final class Settings {
	
	private var _store = DataStore()
	
	var appState = AppState()
	var account = AccountSetting()
	var project = ProjectSetting()

	init() {
	
		loadSettings()
	}
	
	// 設定がされていることを確認します。有効性は判定しません。
	var isReady:Bool {
	
		return account.isReady && project.isReady
	}
	
	func loadSettings() {

		loadAppState()
		loadAccount()
	}
	
	func loadAppState() {
	
		appState.hashtags = _store.appState.hashtags
		appState.selectedLanguage = _store.appState.selectedLanguage
		
		DebugTime.print("App state loaded.")
	}
	
	func saveAppState() {
	
		_store.appState.selectedLanguage = appState.selectedLanguage
		_store.appState.hashtags = appState.hashtags
		
		_store.appState.save()
		
		DebugTime.print("App state saved.")
	}
	
	func loadAccount() {
		
		loadTwitterAccount()
		loadGitHubAccount()
	}
	
	func saveAccount() {
		
		saveTwitterAccount()
		saveGitHubAccount()
	}
	
	func loadTwitterAccount() {
		
		switch _store.twitter.kind {
			
//		case .OSAccount:
//			loadTwitterAccountAsAccount()
			
		case .OAuthToken:
			loadTwitterAccountAsToken()
			
//		case .Unknown:
		case .notAuthorized:
			loadTwitterAccountDefault()
		}
	}
	
//	private func loadTwitterAccountAsAccount() {
//
//		NSLog("🐋 Loading Twitter Account as OS Account.")
//
//		let identifier = _store.twitter.identifier
//
//		if let account = TwitterController.Account(identifier: identifier) {
//
//			NSLog("Twitter account which authenticated by OS restored from data store. (\(account.username))")
//			self.account.twitterAccount = account
//		}
//		else {
//
//			NSLog("Twitter account which authenticated by OS restored from data store but the account is not exists. (\(identifier))")
//		}
//	}
	
	private func loadTwitterAccountAsToken() {
		
		let tokenKey = _store.twitter.token
		let tokenSecret = _store.twitter.tokenSecret
		let tokenScreenName = _store.twitter.tokenScreenName
		let tokenUserId = _store.twitter.tokenUserId
		
//		let account = TwitterController.Account(token: token, tokenSecret: tokenSecret, screenName: tokenScreenName)
		let token = ESTwitter.Token(key: tokenKey, secret: tokenSecret, userId: tokenUserId, screenName: tokenScreenName)
		
		NSLog("Twitter account which authenticated by OAuth restored from data store. (\(token.screenName))")
		
		account.twitterToken = token
	}
	
	private func loadTwitterAccountDefault() {

		NSLog("No Twitter account specified.")
		account.twitterToken = nil
	}

	func saveTwitterAccount() {
		
		NSLog("Writing Twitter account to data store. (\(account.twitterToken?.screenName ?? "(null)"))")
		
		if let token = account.twitterToken {

			_store.twitter.kind = .OAuthToken
			_store.twitter.identifier = ""
			_store.twitter.token = token.key
			_store.twitter.tokenSecret = token.secret
			_store.twitter.tokenScreenName = token.screenName
			_store.twitter.tokenUserId = token.userId
		}
		else {
			
			_store.twitter.kind = .notAuthorized
			_store.twitter.identifier = ""
			_store.twitter.token = ""
			_store.twitter.tokenSecret = ""
			_store.twitter.tokenScreenName = ""
			_store.twitter.tokenUserId = ""
		}
		
		_store.twitter.save()
	}
	
	func loadGitHubAccount() {
		
		account.id = _store.github.authInfo.id
		account.username = _store.github.authInfo.username
		account.authorization = _store.github.authInfo.token.map(GitHubAuthorization.init)

		NSLog("GitHub account information restored from data store. (\(account.username ?? "(null)"))")
		
		Authorization.GitHubAuthorizationStateDidChangeNotification(isValid: account.authorizationState == .Authorized, username: self.account.username).post()
	}

	func saveGitHubAccount() {
		
		NSLog("Writing GitHub account to data store. (\(self.account.username ?? "(null)"))")
		
		_store.github.authInfo.id = account.id
		_store.github.authInfo.username = account.username
		_store.github.authInfo.token = account.authorization?.token!
		
		try! handleError(expression: _store.github.save())
	}
	
	func replaceGitHubAccount(username:String, id:ID, authorization:GitHubAuthorization, saveFinally save:Bool) {
	
		account.id = id
		account.username = username
		account.authorization = authorization

		if save {
			
			saveGitHubAccount()
		}
	}
	
	func resetTwitterAccount(saveFinally save: Bool) {
		
		account.twitterToken = nil
		
		if save {
			
			saveTwitterAccount()
		}
	}
	
	func resetGitHubAccount(saveFinally save: Bool) {
		
		account.id = nil
		account.username = nil
		account.authorization = nil
		
		if save {
			
			saveGitHubAccount()
		}
	}
}
