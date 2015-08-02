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
	
	static let service = "jp.ez-style.appid.CodePiece"

	var github:GitHub

	init() {
		
		self.github = GitHub()
	}
	
	func save() {
	
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
		
		init() {
		
			let keychain = Keychain(service: DataStore.service).synchronizable(true)

			self.id = keychain[GitHub.IDKey].flatMap(ID.init)
			self.username = keychain[GitHub.UsernameKey]
			self.token = keychain[GitHub.TokenKey]
		}
		
		func save() {
			
			let keychain = Keychain(service: DataStore.service).synchronizable(true)
			
			keychain[GitHub.IDKey] = self.id.map { String($0) }
			keychain[GitHub.UsernameKey] = self.username
			keychain[GitHub.TokenKey] = self.token
		}
	}
}