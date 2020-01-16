//
//  Hashtag.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Swim

public protocol HashtagType {

	var value:String { get }
	
	var length:Int { get }
	var isEmpty:Bool { get }

	init?(hashtagValue:String)
}

public struct Hashtag : HashtagType {
	
	private var _value:String!
	
	public init() {
		
		self._value = ""
	}
	
	public init?(hashtagValue: String) {
		
		guard !hashtagValue.isEmpty else {
		
			return nil
		}
		
		self.init(hashtagValue)
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
	
	public var valueWithoutPrefix: String {
		
		if value.hasPrefix("#") {
			
			return value.substringFromIndex(value.startIndex.successor())
		}
		else {
			
			return value
		}
	}
	
	public static func normalize(value:String) -> String {
		
		let value = value.trimmed()
		
		guard !value.isEmpty else {
			
			return ""
		}
		
		guard !meetsAllOf(value.characters, "#") else {
			
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
	
	public var url: NSURL {
		
		return NSURL(scheme: "https", host: "twitter.com", path: "/hashtag/\(valueWithoutPrefix)?f=tweets")!
	}
}

extension Hashtag : CustomStringConvertible {
	
	public var description:String {
		
		return self.value
	}
}

extension Hashtag : Hashable {
	
	public var hashValue: Int {
		
		return self.value.hashValue
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
