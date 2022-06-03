//
//  DataStore.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import KeychainAccess
import ESGists
import Ocean
import Swim

// FIXME: Twitter のデータストアが Keychain ではないため、Gists と合わせる必要あり
@MainActor
struct DataStore {
	
	static let service = "CodePiece App"
	static let group = "jp.ez-style.appid.CodePiece"

	var appState: AppState
	var twitter: TwitterStore
	var gist: GistStore

	init() {
		
		appState = AppState()
		twitter = TwitterStore()
		gist = GistStore()
	}
	
	func save() throws {
	
		appState.save()
		twitter.save()
		try gist.save()
	}
}

extension DataStore {
	
	enum DataStoreError : Error {
		
		case failedToSave(String)
	}
}

extension DataStore.DataStoreError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .failedToSave(let reason):
			return "Failed to save to data store. \(reason)"
		}
	}
}

private extension UserDefaults {
	
	typealias TwitterStoreKind = DataStore.TwitterStore.Kind
	
	static let twitterStoreAccountKindKey = "twitter:kind"
	static let twitterStoreAccountIdentifierKey = "twitter:identifier"
	static let twitterStoreAccountTokenKey = "twitter:token"
	static let twitterStoreAccountTokenSecretKey = "twitter:token-secret"
	static let twitterStoreAccountTokenScreenNameKey = "twitter:token-screenname"
	static let twitterStoreAccountTokenUserIdKey = "twitter:token-userid"

	@MainActor
	var twitterStore: DataStore.TwitterStore {
	
		let identifier = twitterStoreAccountIdentifier
		let token = twitterStoreAccountToken
		let tokenSecret = twitterStoreAccountTokenSecret
		let tokenScreenName = twitterStoreAccountTokenScreenName
		let tokenUserId = twitterStoreAccountTokenUserId
		let kind = twitterStoreAccountKind
		
		return DataStore.TwitterStore(kind: kind, identifier: identifier, token: token, tokenSecret: tokenSecret, tokenScreenName: tokenScreenName, tokenUserId: tokenUserId)
	}

	@MainActor
	func set(twitterStore store: DataStore.TwitterStore) {
		
		twitterStoreAccountIdentifier = store.identifier
		twitterStoreAccountToken = store.token
		twitterStoreAccountTokenSecret = store.tokenSecret
		twitterStoreAccountTokenScreenName = store.tokenScreenName
		twitterStoreAccountTokenUserId = store.tokenUserId
		twitterStoreAccountKind = store.kind
	}
	
	var twitterStoreAccountIdentifier: String {
		
		get {
			
			string(forKey: UserDefaults.twitterStoreAccountIdentifierKey) ?? ""
		}
		
		set (identifier) {
			
			set(identifier, forKey: UserDefaults.twitterStoreAccountIdentifierKey)
		}
	}
	
	var twitterStoreAccountToken: String {
		
		get {
			
			string(forKey: UserDefaults.twitterStoreAccountTokenKey) ?? ""
		}
		
		set (token) {
			
			set(token, forKey: UserDefaults.twitterStoreAccountTokenKey)
		}
	}
	
	var twitterStoreAccountTokenSecret: String {
		
		get {
			
			string(forKey: UserDefaults.twitterStoreAccountTokenSecretKey) ?? ""
		}
		
		set (secret) {
			
			set(secret, forKey: UserDefaults.twitterStoreAccountTokenSecretKey)
		}
	}
	
	var twitterStoreAccountTokenScreenName: String {
		
		get {
			
			string(forKey: UserDefaults.twitterStoreAccountTokenScreenNameKey) ?? ""
		}
		
		set (screenName) {
			
			set(screenName, forKey: UserDefaults.twitterStoreAccountTokenScreenNameKey)
		}
	}
	
	var twitterStoreAccountTokenUserId: String {
		
		get {
			
			string(forKey: UserDefaults.twitterStoreAccountTokenUserIdKey) ?? ""
		}
		
		set (screenName) {
			
			set(screenName, forKey: UserDefaults.twitterStoreAccountTokenUserIdKey)
		}
	}
	
	var twitterStoreAccountKind: TwitterStoreKind {

		get {

			if let kindValue = string(forKey: UserDefaults.twitterStoreAccountKindKey) {

				return TwitterStoreKind(rawValue: kindValue) ?? .notAuthorized
			}
			else {

				return .notAuthorized
			}
		}

		set (kind) {

			set(kind.rawValue, forKey: UserDefaults.twitterStoreAccountKindKey)
		}
	}
}

extension DataStore {

	@MainActor
	struct TwitterStore : UserDefaultAccessible {

		enum Kind : String {

			case notAuthorized = ""
//			case OSAccount = "account"
			case oAuthToken = "token"
		}
		
		var kind: Kind
		var identifier: String
		var token: String
		var tokenSecret: String
		var tokenScreenName: String
		var tokenUserId: String
	}
}

extension DataStore.TwitterStore {
	
	init() {
		
		self = DataStore.TwitterStore.userDefaults.twitterStore
	}
	
	func save() {
		
		userDefaults.set(twitterStore: self)
	}
}

extension DataStore {
	
	@MainActor
	struct GistStore {

		#if DEBUG
		static let AuthorizationKey = "github:debug:auth-info"
		#else
		static let AuthorizationKey = "github:auth-info"
		#endif

		var authInfo: AuthInfo
		
		private static var keychain: Keychain {
			
			// synchronizable すると署名なしのアーカイブ時に読み書きできなくなることがあるため、現在は無効化しています。
			Keychain(service: DataStore.service, accessGroup: DataStore.group)
				.accessibility(Accessibility.whenUnlocked)
//				.synchronizable(true)
		}
		
		init() {
			
			if NSApp.environment.useKeychain {
				
				self.init(useKeychain:())
			}
			else {
				
				self.init(unuseKeychain:())
			}
		}
		
		private init(unuseKeychain: Void) {
			
			NSLog("To using keychain is disabled by CodePiece.")
			authInfo = AuthInfo()
		}
		
		private init(useKeychain: Void) {
		
			let keychain = GistStore.keychain

			do {
				
				guard let data = try keychain.getData(GistStore.AuthorizationKey) else {
					
					authInfo = AuthInfo()
					return
				}
				
				NSLog("Restoring authentication information from Keychain.")
								
				let info = try JSONDecoder().decode(AuthInfo.self, from: data)
									
				authInfo = info
			}
			catch {
				
				NSLog("Failed to get a gist store. Ignoring.")
				authInfo = AuthInfo()
			}
		}
		
		func save() throws {
			
			guard NSApp.environment.useKeychain else {
			
				NSLog("Settings are not keep because to using keychain is disabled by CodePiece.")
				return
			}
			
			let keychain = GistStore.keychain
			let keyForAuthInfo = GistStore.AuthorizationKey

			NSLog("Will save authentication information to Keychain.")
			
			do {

				let data = try JSONEncoder().encode(authInfo)
				
				try keychain.set(data, key: keyForAuthInfo)
			}
			catch {

				NSLog("Failed to save the git store.")
				try keychain.remove(keyForAuthInfo)
				throw DataStoreError.failedToSave(error.localizedDescription)
			}
		}
	}
}
