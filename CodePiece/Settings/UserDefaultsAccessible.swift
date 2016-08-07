//
//  UserDefaultsAccessible.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 8/7/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Foundation

// I must gethering the features to other module and remove the namespace.
struct UserDefaultAccessibleNamespace {

	static let userDefaults = NSUserDefaults.standardUserDefaults()
}

protocol UserDefaultAccessible {
	
}

extension UserDefaultAccessible {
	
	var userDefaults: NSUserDefaults {
		
		return self.dynamicType.userDefaults
	}
	
	static var userDefaults: NSUserDefaults {
		
		return UserDefaultAccessibleNamespace.userDefaults
	}
}
