//
//  Settings.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists

final class Settings {
	
	private var _store:DataStore
	
	var appState:AppState
	var account:AccountSetting
	var project:ProjectSetting

	init() {
	
		self._store = DataStore()

		self.appState = AppState()
		self.account = AccountSetting()
		self.project = ProjectSetting()
		
		self.loadSettings()
	}
	
	// 設定がされていることを確認します。有効性は判定しません。
	var isReady:Bool {
	
		return self.account.isReady && self.project.isReady
	}
	
	func loadSettings() {

		self.loadAppState()
		self.loadAccount()
	}
	
	func loadAppState() {
	
		self.appState.selectedLanguage = self._store.appState.selectedLanguage
		self.appState.hashtags = self._store.appState.hashtags
	}
	
	func saveAppState() {
	
		self._store.appState.selectedLanguage = self.appState.selectedLanguage
		self._store.appState.hashtags = self.appState.hashtags
		
		self._store.appState.save()
	}
	
	func loadAccount() {
		
		self.loadTwitterAccount()
		self.loadGitHubAccount()
	}
	
	func saveAccount() {
		
		self.saveTwitterAccount()
		self.saveGitHubAccount()
	}
	
	func loadTwitterAccount() {
		
		switch self._store.twitter.kind {
			
		case .OSAccount:
			loadTwitterAccountAsAccount()
			
		case .OAuthToken:
			loadTwitterAccountAsToken()
			
		case .Unknown:
			loadTwitterAccountDefault()
		}
	}
	
	private func loadTwitterAccountAsAccount() {
		
		let identifier = self._store.twitter.identifier
		
		if let account = TwitterAccount(identifier: identifier) {
			
			NSLog("Twitter account which authenticated by OS restored from data store. (\(account.username))")
			self.account.twitterAccount = account
		}
		else {
			
			NSLog("Twitter account which authenticated by OS restored from data store but the account is not exists. (\(identifier))")
		}
	}
	
	private func loadTwitterAccountAsToken() {
		
		let token = self._store.twitter.token
		let tokenSecret = self._store.twitter.tokenSecret
		let tokenScreenName = self._store.twitter.tokenScreenName
		
		let account = TwitterAccount(token: token, tokenSecret: tokenSecret, screenName: tokenScreenName)
		
		NSLog("Twitter account which authenticated by OAuth restored from data store. (\(account.username))")
		self.account.twitterAccount = account
	}
	
	private func loadTwitterAccountDefault() {
		
		// If no twitter account specified by settings, adopt registered account in OSX only if single account is registered.
		if let account = TwitterController.getSingleAccount().map(TwitterAccount.init) {
			
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

			self._store.twitter.kind = account.storeKind
			
			switch account {
				
			case let .Account(osAccount):
				self._store.twitter.identifier = osAccount.identifier ?? ""
				self._store.twitter.token = ""
				self._store.twitter.tokenSecret = ""
				self._store.twitter.tokenScreenName = ""
				
			case let .Token(token, tokenSecret, screenName):
				self._store.twitter.identifier = ""
				self._store.twitter.token = token
				self._store.twitter.tokenSecret = tokenSecret
				self._store.twitter.tokenScreenName = screenName
			}
		}
		else {
			
			self._store.twitter.kind = .Unknown
			self._store.twitter.identifier = ""
			self._store.twitter.token = ""
			self._store.twitter.tokenSecret = ""
			self._store.twitter.tokenScreenName = ""
		}
		
		self._store.twitter.save()
	}
	
	func loadGitHubAccount() {
		
		self.account.id = self._store.github.authInfo.id
		self.account.username = self._store.github.authInfo.username
		self.account.authorization = self._store.github.authInfo.token.map(GitHubAuthorization.init)

		NSLog("GitHub account information restored from data store. (\(self.account.username))")
		
		Authorization.GitHubAuthorizationStateDidChangeNotification(isValid: self.account.authorizationState == .Authorized, username: self.account.username).post()
	}

	func saveGitHubAccount() {
		
		NSLog("Writing GitHub account to data store. (\(self.account.username))")
		
		self._store.github.authInfo.id = self.account.id
		self._store.github.authInfo.username = self.account.username
		self._store.github.authInfo.token = self.account.authorization?.token!
		
		handleError(try self._store.github.save())
	}
	
	func replaceGitHubAccount(username:String, id:ID, authorization:GitHubAuthorization, saveFinally save:Bool) {
	
		self.account.id = id
		self.account.username = username
		self.account.authorization = authorization

		if save {
			
			self.saveGitHubAccount()
		}
	}
	
	func resetGitHubAccount(saveFinally save:Bool) {
		
		self.account.id = nil
		self.account.username = nil
		self.account.authorization = nil
		
		if save {
			
			self.saveGitHubAccount()
		}
	}
}
