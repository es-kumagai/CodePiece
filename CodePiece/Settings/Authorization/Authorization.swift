//
//  Authorization.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import KeychainAccess
import ESGist

func authorization(id:String, password:String) {
	
	let keychain = Keychain(service: "jp.ez-style.appid.CodePiece")
	
//	guard let id = keychain["id"], let password = keychain["password"] else {
//		
//		return nil
//	}
//	
//	self.authorization = GitHubAuthorization(id: id, password: password)
}
