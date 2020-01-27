//
//  UsersTag.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

internal typealias SwifterUsersTag = UsersTag

extension API {
	
	public enum UsersTag {
		
		case id([String])
		case screenName([String])
	}
}

extension API.UsersTag {
	
	init(_ usersTag: SwifterUsersTag) {
		
		switch usersTag {
			
		case .id(let values):
			self = .id(values)
			
		case .screenName(let values):
			self = .screenName(values)
		}
	}
}

internal extension SwifterUsersTag {
	
	init(_ usersTag: API.UsersTag) {
		
		switch usersTag {
			
		case .id(let values):
			self = .id(values)
			
		case .screenName(let values):
			self = .screenName(values)
		}
	}
}
