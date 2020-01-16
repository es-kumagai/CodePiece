//
//  Settings.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists

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
	}
	
	func saveAppState() {
	
		_store.appState.selectedLanguage = appState.selectedLanguage
		_store.appState.hashtags = appState.hashtags
		
		_store.appState.save()
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
			
		case .OSAccount:
			loadTwitterAccountAsAccount()
			
		case .OAuthToken:
			loadTwitterAccountAsToken()
			
		case .Unknown:
			loadTwitterAccountDefault()
		}
	}
	
	private func loadTwitterAccountAsAccount() {
		
		NSLog("🐋 Loading Twitter Account as OS Account.")

		let identifier = _store.twitter.identifier
		
		if let account = TwitterController.Account(identifier: identifier) {
			
			NSLog("Twitter account which authenticated by OS restored from data store. (\(account.username))")
			self.account.twitterAccount = account
		}
		else {
			
			NSLog("Twitter account which authenticated by OS restored from data store but the account is not exists. (\(identifier))")
		}
	}
	
	private func loadTwitterAccountAsToken() {
		
		let token = _store.twitter.token
		let tokenSecret = _store.twitter.tokenSecret
		let tokenScreenName = _store.twitter.tokenScreenName
		
		let account = TwitterController.Account(token: token, tokenSecret: tokenSecret, screenName: tokenScreenName)
		
		NSLog("Twitter account which authenticated by OAuth restored from data store. (\(account.username))")
		self.account.twitterAccount = account
	}
	
	private func loadTwitterAccountDefault() {
		
		// If no twitter account specified by settings, adopt registered account in OSX only if single account is registered.
		if let account = TwitterController.getSingleAccount().map(TwitterController.Account.init) {
			
			NSLog("No Twitter account specified. Using account '\(account.username)' which registered in OS.")
			self.account.twitterAccount = account
		}
		else {
			
			NSLog("No Twitter account specified.")
			self.account.twitterAccount = nil
		}
		
		self.saveTwitterAccount()
	}

	func saveTwitterAccount() {
		
		NSLog("Writing Twitter account to data store. (\(self.account.twitterAccount?.username))")
		
		if let account = self.account.twitterAccount {

			_store.twitter.kind = account.storeKind
			
			switch account {
				
			case let .account(osAccount):
				_store.twitter.identifier = osAccount.identifier ?? ""
				_store.twitter.token = ""
				_store.twitter.tokenSecret = ""
				_store.twitter.tokenScreenName = ""
				
			case let .token(token, tokenSecret, screenName):
				_store.twitter.identifier = ""
				_store.twitter.token = token
				_store.twitter.tokenSecret = tokenSecret
				_store.twitter.tokenScreenName = screenName
			}
		}
		else {
			
			_store.twitter.kind = .Unknown
			_store.twitter.identifier = ""
			_store.twitter.token = ""
			_store.twitter.tokenSecret = ""
			_store.twitter.tokenScreenName = ""
		}
		
		_store.twitter.save()
	}
	
	func loadGitHubAccount() {
		
		account.id = _store.github.authInfo.id
		account.username = _store.github.authInfo.username
		account.authorization = _store.github.authInfo.token.map(GitHubAuthorization.init)

		NSLog("GitHub account information restored from data store. (\(account.username))")
		
		Authorization.GitHubAuthorizationStateDidChangeNotification(isValid: account.authorizationState == .Authorized, username: self.account.username).post()
	}

	func saveGitHubAccount() {
		
		NSLog("Writing GitHub account to data store. (\(self.account.username))")
		
		_store.github.authInfo.id = account.id
		_store.github.authInfo.username = account.username
		_store.github.authInfo.token = account.authorization?.token!
		
		handleError(try _store.github.save())
	}
	
	func replaceGitHubAccount(username:String, id:ID, authorization:GitHubAuthorization, saveFinally save:Bool) {
	
		account.id = id
		account.username = username
		account.authorization = authorization

		if save {
			
			saveGitHubAccount()
		}
	}
	
	func resetGitHubAccount(saveFinally save:Bool) {
		
		account.id = nil
		account.username = nil
		account.authorization = nil
		
		if save {
			
			saveGitHubAccount()
		}
	}
}
