//
//  Settings.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists

var settings = Settings()

struct Settings {
	
	private var _store:DataStore!
	
	var account:AccountSetting
	var project:ProjectSetting
	
	private init() {
	
		self.account = AccountSetting()
		self.project = ProjectSetting()
		
		self.loadAccount()
	}
	
	// 設定がされていることを確認します。有効性は判定しません。
	var isReady:Bool {
	
		return self.account.isReady && self.project.isReady
	}
	
	mutating func loadAccount() {
		
		self.loadGitHubAccount()
	}
	
	mutating func saveAccount() {
		
		self.saveGitHubAccount()
	}
	
	mutating func loadGitHubAccount() {
		
		self._store = DataStore()
		
		self.account.id = self._store.github.id
		self.account.username = self._store.github.username
		self.account.authorization = self._store.github.token.map(GitHubAuthorization.init)
	}
	
	mutating func saveGitHubAccount() {
		
		self._store.github.id = self.account.id
		self._store.github.username = self.account.username
		self._store.github.token = self.account.authorization?.token!
		
		self._store.save()
	}
	
	mutating func replaceGitHubAccount(username:String, authorization:AuthorizationResponse) {
	
		self.account.id = authorization.id
		self.account.username = username
		self.account.authorization = .Token(authorization.token.value)
		
		self.saveGitHubAccount()
	}
	
	mutating func updateGitHubAccount(username:String, authorization:AuthorizationResponse) {
		
		// 更新時はトークンを書き換えません。
		self.account.id = authorization.id
		self.account.username = username
		
		self.saveGitHubAccount()
	}
	
	mutating func resetGitHubAccount() {
		
		self.account.id = nil
		self.account.username = nil
		self.account.authorization = nil
		
		self.saveGitHubAccount()
	}
}
