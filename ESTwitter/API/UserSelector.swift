//
//  UserSelector.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

extension API {

	public enum UserSelector {

		case id(String)
		case screenName(String)
	}
}

extension API.UserSelector {
	
	public init(_ tag: UserTag) {
		
		switch tag {
			
		case .id(let value):
			self = .id(value)
			
		case .screenName(let value):
			self = .screenName(value)
		}
	}
}

extension UserTag {
	
	init(_ selector: API.UserSelector) {
		
		switch selector {
			
		case .id(let value):
			self = .id(value)
			
		case .screenName(let value):
			self = .screenName(value)
		}
	}
}
