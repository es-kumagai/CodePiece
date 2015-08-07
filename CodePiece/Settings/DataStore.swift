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

struct DataStore {
	
	static let service = "CodePiece App"
	static let group = "jp.ez-style.appid.CodePiece"

	var appState:AppState
	var github:GitHub

	init() {
		
		self.appState = AppState()
		self.github = GitHub()
	}
	
	func save() {
	
		self.appState.save()
		self.github.save()
	}
}

extension DataStore {
	
	struct GitHub {

		static let AuthorizationKey = "github:auth-info"

		var authInfo:AuthInfo
		
		private static var keychain:Keychain {
			
			// synchronizable すると署名なしのアーカイブ時に読み書きできなくなることがあるため、現在は無効化しています。
			return Keychain(service: DataStore.service, accessGroup:DataStore.group)
				.accessibility(Accessibility.WhenUnlocked)
//				.synchronizable(true)
		}
		
		init() {
		
			let keychain = GitHub.keychain
			
			guard let data = keychain.getData(GitHub.AuthorizationKey) else {
			
				self.authInfo = AuthInfo()
				return
			}
			
			NSLog("Restoring authentication information from Keychain.")
			
			guard let authInfo = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? AuthInfo else {
					
				self.authInfo = AuthInfo()
				return
			}

			self.authInfo = authInfo
		}
		
		func save() {
			
			let keychain = GitHub.keychain
			let keyForAuthInfo = GitHub.AuthorizationKey

			NSLog("Will save authentication information to Keychain.")
			
			if let data = self.archiveAuthorizationData() {
				
				keychain.set(data, key: keyForAuthInfo)
			}
			else {
				
				keychain.remove(keyForAuthInfo)
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
