//
//  UserDefaultsAccessible.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 8/7/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import class Foundation.UserDefaults

// I must gethering the features to other module and remove the namespace.
struct UserDefaultAccessibleNamespace {

	static let userDefaults = UserDefaults.standard
}

protocol UserDefaultAccessible {
	
}

extension UserDefaultAccessible {
	
	var userDefaults: UserDefaults {
		
		return Self.userDefaults
	}
	
	static var userDefaults: UserDefaults {
		
		return UserDefaultAccessibleNamespace.userDefaults
	}
}
