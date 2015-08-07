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
		
		let id = (aDecoder.decodeObjectForKey(ArchiveKey.ID) as? NSNumber).map { ID($0.unsignedLongLongValue) }
		let username = aDecoder.decodeObjectForKey(ArchiveKey.Username) as? String
		let token = aDecoder.decodeObjectForKey(ArchiveKey.Token) as? String
		
		self.init(id: id, username: username, token: token)
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		
		aCoder.encodeObject((self.id?.value).map({NSNumber(unsignedLongLong: $0)}), forKey: ArchiveKey.ID)
		aCoder.encodeObject(self.username, forKey: ArchiveKey.Username)
		aCoder.encodeObject(self.token, forKey: ArchiveKey.Token)
	}
	
	var noData:Bool {
		
		if case (.None, .None, .None) = (self.id, self.username, self.token) {
			
			return true
		}
		else {
			
			return false
		}
	}
}
