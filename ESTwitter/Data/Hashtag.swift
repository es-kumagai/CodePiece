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
	
	private var rawValue: String
	
	public init() {
		
		rawValue = ""
	}
	
	public init?(hashtagValue: String) {
		
		guard !hashtagValue.isEmpty else {
		
			return nil
		}
		
		self.init(hashtagValue)
	}

	public init(_ value: String) {
		
		self.init()
		self.value = value
	}
	
	public var value: String {
		
		get {
			
			return rawValue
		}
		
		set {
			
			rawValue = Hashtag.normalize(newValue)
		}
	}
}

extension Hashtag {
	
	public var valueWithoutPrefix: String {
		
		if value.hasPrefix("#") {
			
			let index = value.index(after: value.startIndex)
			
			return String(value.suffix(from: index))
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
		
		return value.utf16.count
	}
	
	public var isEmpty:Bool {
		
		return value.isEmpty
	}
	
	public var url: TwitterURL {
		
		TwitterURL(rawValue: "https://twitter.com/hashtag/\(valueWithoutPrefix)?f=tweets")
	}
}

extension Hashtag : CustomStringConvertible {
	
	public var description:String {
		
		return value
	}
}

extension Hashtag : Hashable {
	
	public func hash(into hasher: inout Hasher) {
		
		hasher.combine(rawValue)
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
