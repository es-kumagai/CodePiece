//
//  Hashtag.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Swim

public protocol HashtagType {

	var value: String { get }
	
	var length: Int { get }
	var isEmpty: Bool { get }

	init?(hashtagValue:String)
}

public struct Hashtag : HashtagType {
	
	private var rawValue: String!
	
	public init() {
		
		self.rawValue = ""
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
	
	public var value: String {
		
		get {
			
			return self.rawValue
		}
		
		set {
			
			self.value = Hashtag.normalize(newValue)
		}
	}
}

extension Hashtag {
	
	public var valueWithoutPrefix: String {
		
		if value.hasPrefix("#") {
			
			return value.substring(from: value.index(after: value.startIndex))
		}
		else {
			
			return value
		}
	}
	
	public static func normalize(_ value: String) -> String {
		
		let value = value.trimmingCharacters(in: .whitespaces)
		
		guard !value.isEmpty else {
			
			return ""
		}
		
		guard !value.meetsAll(of: "#") else {
			
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
	
	public var url: Foundation.URL {
		
		return NSURL(scheme: "https", host: "twitter.com", path: "/hashtag/\(valueWithoutPrefix)?f=tweets")! as Foundation.URL
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

extension Hashtag : ExpressibleByStringLiteral {
	
	public init(stringLiteral value: String) {
		
		self.init(value)
	}
}

extension Hashtag : Decodable {
	
	public init(from decoder: Decoder) throws {
		
		rawValue = try decoder.singleValueContainer().decode(String.self)
	}
}
