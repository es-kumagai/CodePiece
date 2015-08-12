//
//  Settings.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists

struct Settings {
	
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
	
	mutating func loadSettings() {

		self.loadAppState()
		self.loadAccount()
	}
	
	mutating func loadAppState() {
	
		self.appState.selectedLanguage = self._store.appState.selectedLanguage
		self.appState.hashtag = self._store.appState.hashtag
	}
	
	mutating func saveAppState() {
	
		self._store.appState.selectedLanguage = self.appState.selectedLanguage
		self._store.appState.hashtag = self.appState.hashtag
		
		self._store.appState.save()
	}
	
	mutating func loadAccount() {
		
		self.loadGitHubAccount()
	}
	
	mutating func saveAccount() {
		
		self.saveGitHubAccount()
	}
	
	mutating func loadGitHubAccount() {
		
		self.account.id = self._store.github.authInfo.id
		self.account.username = self._store.github.authInfo.username
		self.account.authorization = self._store.github.authInfo.token.map(GitHubAuthorization.init)

		NSLog("GitHub account information restored from data store. (\(self.account.username))")
		
		Authorization.GitHubAuthorizationStateDidChangeNotification(username: self.account.username).post()
	}
	
	mutating func saveGitHubAccount() {
		
		NSLog("Writing GitHub account to data store. (\(self.account.username))")
		
		self._store.github.authInfo.id = self.account.id
		self._store.github.authInfo.username = self.account.username
		self._store.github.authInfo.token = self.account.authorization?.token!
		
		self._store.github.save()
	}
	
	mutating func replaceGitHubAccount(username:String, id:ID, authorization:GitHubAuthorization, saveFinally save:Bool) {
	
		self.account.id = id
		self.account.username = username
		self.account.authorization = authorization

		if save {
			
			settings.saveGitHubAccount()
		}
	}
	
	mutating func resetGitHubAccount(saveFinally save:Bool) {
		
		self.account.id = nil
		self.account.username = nil
		self.account.authorization = nil
		
		if save {
			
			settings.saveGitHubAccount()
		}
	}
}
