//
//  Hashtag.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki
import Swim

public struct Hashtag {
	
	private var _value:String!
	
	public init() {
		
		self._value = ""
	}
	
	public init(_ value:String) {
		
		self.value = value
	}
	
	public var value:String {
		
		get {
			
			return self._value
		}
		
		set {
			
			self._value = Hashtag.normalize(newValue)
		}
	}
}

extension Hashtag {
	
	public static func normalize(value:String) -> String {
		
		let value = value.trimmed()
		
		guard  !value.isEmpty else {
			
			return ""
		}
		
		return value.hasPrefix("#") ? value : "#\(value)"
	}
	
	public var length:Int {
		
		return self.value.utf16.count
	}
	
	public var isEmpty:Bool {
		
		return self.value.isEmpty
	}
}

extension Hashtag : CustomStringConvertible {
	
	public var description:String {
		
		return self.value
	}
}

extension Hashtag : Equatable {
	
}

public func == (lhs:Hashtag, rhs:Hashtag) -> Bool{
	
	return lhs.value == rhs.value
}

extension Hashtag : StringLiteralConvertible {
	
	public init(extendedGraphemeClusterLiteral value: String) {
		
		self.init(value)
	}
	
	public init(stringLiteral value: String) {
		
		self.init(value)
	}
	
	public init(unicodeScalarLiteral value: String) {
		
		self.init(value)
	}
}

extension Hashtag : Decodable {
	
	public static func decode(e: Extractor) throws -> Hashtag {

		return try Hashtag(String.decode(e))
	}
}
