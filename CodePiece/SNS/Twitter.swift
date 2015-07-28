//
//  Twitter.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/28.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

struct Twitter {
	
	struct Hashtag {
		
		var value:String
		
		init() {
		
			self.value = ""
		}
		
		init(_ value:String) {
			
			guard !value.isEmpty else {
				
				self.value = ""
				return
			}
			
			self.value = value.hasPrefix("#") ? value : "#\(value)"
		}
	}
	
	enum SpecialCounting {
		
		case Media
		case HTTPUrl
		case HTTPSUrl
	}
}

extension Twitter.Hashtag {
	
	var length:Int {
		
		return self.value.utf16.count
	}
	
	var isEmpty:Bool {
		
		return self.value.isEmpty
	}
}

extension Twitter.Hashtag : CustomStringConvertible {

	var description:String {
		
		return self.value
	}
}

extension Twitter.Hashtag : StringLiteralConvertible {
	
	init(extendedGraphemeClusterLiteral value: String) {
		
		self.init(value)
	}
	
	init(stringLiteral value: String) {

		self.init(value)
	}
	
	init(unicodeScalarLiteral value: String) {

		self.init(value)
	}
}

extension Twitter.SpecialCounting {
	
	var length:Int {
		
		switch self {
			
		case .Media:
			return 23
			
		case .HTTPUrl:
			return 22
			
		case .HTTPSUrl:
			return 23
		}
	}
}
