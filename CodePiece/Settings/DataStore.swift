//
//  DataStore.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import KeychainAccess
import ESGists

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

		static let IDKey = "github:id"
		static let UsernameKey = "github:username"
		static let TokenKey = "github:token"

		var id:ID?
		var username:String?
		var token:String?

		private var keychain:Keychain {
			
			// synchronizable すると署名なしのアーカイブ時に読み書きできなくなることがあるため、現在は無効化しています。
			return Keychain(service: DataStore.service, accessGroup:DataStore.group)
				.accessibility(Accessibility.WhenUnlocked)
//				.synchronizable(true)
		}
		
		init() {
		
			let keychain = self.keychain

			self.id = keychain[GitHub.IDKey].flatMap(ID.init)
			self.username = keychain[GitHub.UsernameKey]
			self.token = keychain[GitHub.TokenKey]
		}
		
		func save() {
			
			let keychain = self.keychain

			keychain[GitHub.IDKey] = self.id.map { String($0) }
			keychain[GitHub.UsernameKey] = self.username
			keychain[GitHub.TokenKey] = self.token
		}
	}
}