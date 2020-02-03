//
//  Character.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/03.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

public struct UTF8Character : RawRepresentable {

	public var rawValue: UInt8
	
	public init(rawValue value: UInt8) {
		
		rawValue = value
	}
}

public struct UTF16Character : RawRepresentable {

	public var rawValue: UInt16
	
	public init(rawValue value: UInt16) {
		
		rawValue = value
	}
}

extension UTF8Character : Comparable {

	public static func == (lhs: UTF8Character, rhs: UTF8Character) -> Bool {
		
		return lhs.rawValue == rhs.rawValue
	}
	
	public static func < (lhs: UTF8Character, rhs: UTF8Character) -> Bool {
		
		return lhs.rawValue < rhs.rawValue
	}
}

extension UTF16Character : Comparable {

	public static func == (lhs: UTF16Character, rhs: UTF16Character) -> Bool {
		
		return lhs.rawValue == rhs.rawValue
	}
	
	public static func < (lhs: UTF16Character, rhs: UTF16Character) -> Bool {
		
		return lhs.rawValue < rhs.rawValue
	}
}

extension UTF8Character {
	
	public var isUtf8LeadingByte: Bool {
		
		return rawValue & 0xC0 != 0x80
	}
	
	public var isAscii: Bool {

		return rawValue & 0x80 == 0
	}
}

extension UTF16Character {
	
	/// Variation Selector 15
	public static let tpvs = UTF16Character(rawValue: 0xFE0E)
	
	/// Variation Selector 16
	public static let epvs = UTF16Character(rawValue: 0xFE0F)
	
	/// Zero Width Joiner
	public static let zwj = UTF16Character(rawValue: 0x200D)
	
	public var isTPVS: Bool {
		
		return self == .tpvs
	}
	
	public var isEPVS: Bool {
		
		return self == .epvs
	}
	
	public var isZWJ: Bool {
		
		return self == .zwj
	}
	
	public var isSurrogateHight: Bool {
		
		return (0xD800 ... 0xDBFF).contains(rawValue)
	}

	public var isSurrogateLow: Bool {
		
		return (0xDC00 ... 0xDFFF).contains(rawValue)
	}
}

extension Character {
	
	public var utf8LeadingByteCount: Int {
		
		return utf8.map(UTF8Character.init).utf8LeadingByteCount
	}
}

extension Sequence where Element == UTF8Character {
	
	public var utf8LeadingByteCount: Int {

		return filter { $0.isUtf8LeadingByte }.count
	}
}
