//
//  DataStore_AuthInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/07.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESGists

private struct ArchiveKey : Sendable {
	
	static let ID = "ID"
	static let Username = "Username"
	static let Token = "Token"
}

struct AuthInfo : Codable, Sendable {
	
	var id: ID?
	var username: String?
	var token: String?
	
	init() {
		
		self.init(id: nil, username: nil, token: nil)
	}
	
	init(id: ID?, username: String?, token: String?) {
		
		self.id = id
		self.username = username
		self.token = token
	}
	
	var noData: Bool {
		
		if case (.none, .none, .none) = (id, username, token) {
			
			return true
		}
		else {
			
			return false
		}
	}
}
