//
//  DataStore_AuthInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/07.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESGists

private struct ArchiveKey {
	
	static let ID = "ID"
	static let Username = "Username"
	static let Token = "Token"
}

// Important!
// The name specified with @objc must not be change.
// If this name change, raise EXCEPTION in NSKeyedUnarchiver.unarchiveObjectWithData.

// FIXME: Objective-C 互換である必要がなさそう。NSKeyedUnarchiver を使うのをやめれば問題ないのかもしれない。
@objc(ESDataStoreAuthInfo)
class AuthInfo : NSObject, NSCoding {
	
	var id:ID?
	var username:String?
	var token:String?
	
	convenience override init() {
		
		self.init(id: nil, username: nil, token: nil)
	}
	
	init(id: ID?, username:String?, token:String?) {
		
		self.id = id
		self.username = username
		self.token = token
		
		super.init()
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		
		let id = (aDecoder.decodeObject(forKey: ArchiveKey.ID) as? NSNumber).map { ID($0.uint64Value) }
		let username = aDecoder.decodeObject(forKey: ArchiveKey.Username) as? String
		let token = aDecoder.decodeObject(forKey: ArchiveKey.Token) as? String
		
		self.init(id: id, username: username, token: token)
	}
	
	func encode(with aCoder: NSCoder) {
		
		aCoder.encode((id?.value).map({NSNumber(value: $0)}), forKey: ArchiveKey.ID)
		aCoder.encode(username, forKey: ArchiveKey.Username)
		aCoder.encode(token, forKey: ArchiveKey.Token)
	}
	
	var noData:Bool {
		
		if case (.none, .none, .none) = (id, username, token) {
			
			return true
		}
		else {
			
			return false
		}
	}
}
