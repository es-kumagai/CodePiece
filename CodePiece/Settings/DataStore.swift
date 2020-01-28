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

struct DataStore {
	
	static let service = "CodePiece App"
	static let group = "jp.ez-style.appid.CodePiece"

	var appState: AppState
	var twitter: TwitterStore
	var github: GitHubStore

	init() {
		
		self.appState = AppState()
		self.twitter = TwitterStore()
		self.github = GitHubStore()
	}
	
	func save() throws {
	
		appState.save()
		twitter.save()
		try github.save()
	}
}

extension DataStore {
	
	enum DataStoreError : Error {
		
		case failedToSave(String)
	}
}

extension DataStore.DataStoreError : CustomStringConvertible {
	
	var description:String {
		
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

	var twitterStore: DataStore.TwitterStore {
	
		let identifier = twitterStoreAccountIdentifier
		let token = twitterStoreAccountToken
		let tokenSecret = twitterStoreAccountTokenSecret
		let tokenScreenName = twitterStoreAccountTokenScreenName
		let tokenUserId = twitterStoreAccountTokenUserId
		let kind = twitterStoreAccountKind
		
		return DataStore.TwitterStore(kind: kind, identifier: identifier, token: token, tokenSecret: tokenSecret, tokenScreenName: tokenScreenName, tokenUserId: tokenUserId)
	}

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
			
			return string(forKey: UserDefaults.twitterStoreAccountIdentifierKey) ?? ""
		}
		
		set (identifier) {
			
			set(identifier, forKey: UserDefaults.twitterStoreAccountIdentifierKey)
		}
	}
	
	var twitterStoreAccountToken: String {
		
		get {
			
			return string(forKey: UserDefaults.twitterStoreAccountTokenKey) ?? ""
		}
		
		set (token) {
			
			set(token, forKey: UserDefaults.twitterStoreAccountTokenKey)
		}
	}
	
	var twitterStoreAccountTokenSecret: String {
		
		get {
			
			return string(forKey: UserDefaults.twitterStoreAccountTokenSecretKey) ?? ""
		}
		
		set (secret) {
			
			set(secret, forKey: UserDefaults.twitterStoreAccountTokenSecretKey)
		}
	}
	
	var twitterStoreAccountTokenScreenName: String {
		
		get {
			
			return string(forKey: UserDefaults.twitterStoreAccountTokenScreenNameKey) ?? ""
		}
		
		set (screenName) {
			
			set(screenName, forKey: UserDefaults.twitterStoreAccountTokenScreenNameKey)
		}
	}
	
	var twitterStoreAccountTokenUserId: String {
		
		get {
			
			return string(forKey: UserDefaults.twitterStoreAccountTokenUserIdKey) ?? ""
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

	struct TwitterStore : UserDefaultAccessible {

		enum Kind : String {

			case notAuthorized = ""
//			case OSAccount = "account"
			case OAuthToken = "token"
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
	
	struct GitHubStore {

		static let AuthorizationKey = "github:auth-info"

		var authInfo:AuthInfo
		
		private static var keychain:Keychain {
			
			// synchronizable すると署名なしのアーカイブ時に読み書きできなくなることがあるため、現在は無効化しています。
			return Keychain(service: DataStore.service, accessGroup: DataStore.group)
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
		
		private init(unuseKeychain:Void) {
			
			NSLog("To using keychain is disabled by CodePiece.")
			self.authInfo = AuthInfo()
		}
		
		private init(useKeychain:Void) {
		
			let keychain = GitHubStore.keychain

			guard let data = handleError(expression: try! keychain.getData(GitHubStore.AuthorizationKey), to: &OutputStream), data != nil else {
		
				self.authInfo = AuthInfo()
				return
			}
			
			NSLog("Restoring authentication information from Keychain.")
			
			guard let authInfo = NSKeyedUnarchiver.unarchiveObject(with: data!) as? AuthInfo else {
				
				self.authInfo = AuthInfo()
				return
			}
			
			self.authInfo = authInfo
		}
		
		func save() throws {
			
			guard NSApp.environment.useKeychain else {
			
				NSLog("Settings are not keep because to using keychain is disabled by CodePiece.")
				return
			}
			
			let keychain = GitHubStore.keychain
			let keyForAuthInfo = GitHubStore.AuthorizationKey

			NSLog("Will save authentication information to Keychain.")
			
			do {

				if let data = self.archiveAuthorizationData() {
				
					try keychain.set(data, key: keyForAuthInfo)
				}
				else {
				
					try keychain.remove(keyForAuthInfo)
				}
			}
			catch let error as NSError {
				
				throw DataStoreError.failedToSave(error.localizedDescription)
			}
		}
		
		private func archiveAuthorizationData() -> Data? {

			guard !self.authInfo.noData else {

				return nil
			}
			
			return NSKeyedArchiver.archivedData(withRootObject: self.authInfo)
		}
	}
}
