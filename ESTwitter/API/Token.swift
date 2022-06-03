//
//  Token.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

public struct Token : Sendable {
	
	public var key: String
	public var secret: String
	public var userId: String
	public var screenName: String
	
	public init(key: String, secret: String, userId: String, screenName: String) {
		
		self.key = key
		self.secret = secret
		self.userId = userId
		self.screenName = screenName
	}
}
