//
//  DataStore.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import KeychainAccess
import ESGists
import Ocean
import Swim

enum DataStoreError : ErrorType, CustomStringConvertible {
	
	case FailedToSave(String)
	
	var description:String {
		
		switch self {
			
		case .FailedToSave(let reason):
			return "Failed to save to data store. \(reason)"
		}
	}
}

struct DataStore {
	
	static let service = "CodePiece App"
	static let group = "jp.ez-style.appid.CodePiece"

	var appState:AppState
	var twitter:TwitterStore
	var github:GitHubStore

	init() {
		
		self.appState = AppState()
		self.twitter = TwitterStore()
		self.github = GitHubStore()
	}
	
	func save() throws {
	
		self.appState.save()
		self.twitter.save()
		try self.github.save()
	}
}

extension DataStore {

	struct TwitterStore {
		
		static let AccountIdentifierKey = "twitter:identifier"
		
		var identifier:String?
		
		init() {
			
			let userDefaults = NSUserDefaults.standardUserDefaults()
			
			self.identifier = userDefaults.stringForKey(TwitterStore.AccountIdentifierKey)
		}
		
		func save() {
			
			let userDefaults = NSUserDefaults.standardUserDefaults()
			
			userDefaults.setObject(self.identifier, forKey: TwitterStore.AccountIdentifierKey)
		}
	}
}

extension DataStore {
	
	struct GitHubStore {

		static let AuthorizationKey = "github:auth-info"

		var authInfo:AuthInfo
		
		private static var keychain:Keychain {
			
			// synchronizable すると署名なしのアーカイブ時に読み書きできなくなることがあるため、現在は無効化しています。
			return Keychain(service: DataStore.service, accessGroup:DataStore.group)
				.accessibility(Accessibility.WhenUnlocked)
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

			guard let data = handleError(try keychain.getData(GitHubStore.AuthorizationKey), to: &OutputStream) where data != nil else {
		
				self.authInfo = AuthInfo()
				return
			}
			
			NSLog("Restoring authentication information from Keychain.")
			
			guard let authInfo = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? AuthInfo else {
				
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
				
				throw DataStoreError.FailedToSave(error.localizedDescription)
			}
		}
		
		private func archiveAuthorizationData() -> NSData? {

			guard !self.authInfo.noData else {

				return nil
			}
			
			return NSKeyedArchiver.archivedDataWithRootObject(self.authInfo)
		}
	}
}
