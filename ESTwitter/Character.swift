//
//  Character.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/02/02.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension String {
	
	public var twitterCharacterView: [TwitterCharacter] {
		
		return map(TwitterCharacter.init)
	}
}

public struct TwitterCharacter {
	
	private(set) var units: [UTF16Character]
	
	public init(_ character: Character) {
	
		units = character.utf16.map(UTF16Character.init)
	}
}

extension TwitterCharacter {
	
	public var rawString: String {
	
		return units
			.map { $0.rawValue }
			.withUnsafeBufferPointer { buffer in

			guard let address = buffer.baseAddress else {
				
				return ""
			}
			
			return String(utf16CodeUnits: address, count: buffer.count)
		}
	}
	
	public var utf8: String.UTF8View {
		
		return rawString.utf8
	}
	
	public var unitCount: Int {
	
		return units.count
	}
	
	public func contains(_ element: UTF16Character) -> Bool {
		
		return units.contains(element)
	}

	public var wordCountForPost: Double {

		if isEnglish {
			
			return 0.5
		}
		else if contains(.tpvs)  {

			return 2
		}
		else {
			
			return 1
		}
	}

	public var wordCountForIndices: Int {
		
		return utf8.map(UTF8Character.init).utf8LeadingByteCount
	}
	
	public var isEnglish: Bool {
		
		guard units.count == 1 else {
			
			return false
		}
		
		switch units.first!.rawValue {
			
		case 0x0000 ... 0x10FF,
			 0x2000 ... 0x200D,
			 0x2010 ... 0x201F,
			 0x2032 ... 0x2037:
			return true
			
		default:
			return false
		}
	}
	
	public var isSurrogatePair: Bool {
		
		guard units.count == 2 else {
			
			return false
		}
		
		return units[0].isSurrogateHight && units[1].isSurrogateLow
	}
}

extension Sequence where Element == TwitterCharacter {
	
	public var wordCountForPost: Double {
		
		return reduce(0) { $0 + $1.wordCountForPost }
	}
}
