//
//  Settings.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import ESGists
import ESTwitter
import CodePieceCore

@MainActor
final class Settings {
	
	private var _store: DataStore	// FIXME: 存在が冗長な印象
	
	var appState = AppState()
	var account = AccountSetting()
	var project = ProjectSetting()

	init() {
	
		_store = DataStore()
		
		loadSettings()
	}
	
	// 設定がされていることを確認します。有効性は判定しません。
	var isReady: Bool {
	
		return account.isReady && project.isReady
	}
	
	func loadSettings() {

		loadAppState()
		loadAccount()
	}
	
	func loadAppState() {
	
		appState.hashtags = _store.appState.hashtags
		appState.selectedLanguage = _store.appState.selectedLanguage
		appState.description = _store.appState.description
		appState.code = _store.appState.code
		
		DebugTime.print("App state loaded.")
	}
	
	func saveAppState() {
	
		_store.appState.selectedLanguage = appState.selectedLanguage
		_store.appState.hashtags = appState.hashtags
		_store.appState.description = appState.description
		_store.appState.code = appState.code
		
		_store.appState.save()
		
		DebugTime.print("App state saved.")
	}
	
	func loadAccount() {
		
		loadTwitterAccount()
		loadGistAccount()
	}
	
	func saveAccount() {
		
		saveTwitterAccount()
		saveGistAccount()
	}
	
	func loadTwitterAccount() {
		
		switch _store.twitter.kind {
			
		case .oAuthToken:
			loadTwitterAccountAsToken()
			
		case .notAuthorized:
			loadTwitterAccountDefault()
		}
	}
	
	private func loadTwitterAccountAsToken() {
		
		let tokenKey = _store.twitter.token
		let tokenSecret = _store.twitter.tokenSecret
		let tokenScreenName = _store.twitter.tokenScreenName
		let tokenUserId = _store.twitter.tokenUserId
		
		let token = ESTwitter.Token(key: tokenKey, secret: tokenSecret, userId: tokenUserId, screenName: tokenScreenName)
		
		Log.information("Twitter account which authenticated by OAuth restored from data store. (\(token.screenName))")
		
		account.twitterToken = token
	}
	
	private func loadTwitterAccountDefault() {

		Log.warning("No Twitter account specified.")
		account.twitterToken = nil
	}

	func saveTwitterAccount() {
		
		Log.information("Writing Twitter account to data store. (\(account.twitterToken?.screenName ?? "(null)"))")
		
		if let token = account.twitterToken {

			_store.twitter.kind = .oAuthToken
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
	
	func loadGistAccount() {
		
		account.id = _store.gist.authInfo.id
		account.username = _store.gist.authInfo.username
		account.authorization = _store.gist.authInfo.token.map(GitHubAuthorization.init)

		Log.information("Gist account information restored from data store. (\(account.username ?? "(null)"))")
		
		Authorization.GistAuthorizationStateDidChangeNotification(isValid: account.authorizationState == .authorized, username: account.username).post()
	}

	func saveGistAccount() {
		
		Log.information("Writing Gist account to data store. (\(account.username ?? "(null)"))")
		
		_store.gist.authInfo.id = account.id
		_store.gist.authInfo.username = account.username
		_store.gist.authInfo.token = account.authorization?.token!
		
		try! handleError(expression: _store.gist.save())
	}
	
	func replaceGistAccount(username: String, id: ID, authorization: GitHubAuthorization, saveFinally save: Bool) {
	
		account.id = id
		account.username = username
		account.authorization = authorization

		if save {
			
			saveGistAccount()
		}
	}
	
	func resetTwitterAccount(saveFinally save: Bool) {
		
		account.twitterToken = nil
		
		if save {
			
			saveTwitterAccount()
		}
	}
	
	func resetGistAccount(saveFinally save: Bool) {
		
		account.id = nil
		account.username = nil
		account.authorization = nil
		
		if save {
			
			saveGistAccount()
		}
	}
}
