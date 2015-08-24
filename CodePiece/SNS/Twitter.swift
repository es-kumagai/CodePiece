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
		
		private var _value:String!
		
		init() {
		
			self._value = ""
		}
		
		init(_ value:String) {
			
			self.value = value
		}
		
		var value:String {
			
			get {
				
				return self._value
			}
			
			set {
				
				self._value = Hashtag.normalize(newValue)
			}
		}
	}
	
	enum SpecialCounting {
		
		case Media
		case HTTPUrl
		case HTTPSUrl
	}
}

extension Twitter.Hashtag {
	
	static func normalize(value:String) -> String {
		
		let value = value.trimmed()
		
		guard  !value.isEmpty else {
			
			return ""
		}
		
		return value.hasPrefix("#") ? value : "#\(value)"
	}
	
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

extension Twitter.Hashtag : Equatable {

}

func == (lhs:Twitter.Hashtag, rhs:Twitter.Hashtag) -> Bool{
	
	return lhs.value == rhs.value
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
