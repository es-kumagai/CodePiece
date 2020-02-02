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
	
	private(set) var rawCharacters: [unichar]
	
	public init(_ character: Character) {
	
		rawCharacters = character.utf16.map { $0 }
	}
}

extension TwitterCharacter {
	
	public var rawValue: String {
	
		return rawCharacters.withUnsafeBufferPointer { buffer in

			guard let address = buffer.baseAddress else {
				
				return ""
			}
			
			return String(utf16CodeUnits: address, count: buffer.count)
		}
	}

	public var wordCountForPost: Double {

		if isEnglish {
			
			return 0.5
		}
		else {

			let tpvs = rawCharacters.indexes { $0 == 0xFE0E }
		
			return 1 + Double(tpvs.count)
		}
	}

	public var wordCountForIndices: Int {
		
		let tpvs = rawCharacters.indexes { $0 == 0xFE0E }
		
		// Entities で受け取る indices の文字カウントは、絵文字を２と扱う様子
		// UTF8 のコードポイント単位で計算しているらしいとの情報があるので実装を変える必要があるかもしれない。
		let epvs = rawCharacters.indexes { $0 == 0xFE0F }

		return 1 + tpvs.count + epvs.count
	}
	
	public var isEnglish: Bool {
		
		guard rawCharacters.count == 1 else {
			
			return false
		}
		
		switch rawCharacters.first! {
			
		case 0x0000 ... 0x10FF,
			 0x2000 ... 0x200D,
			 0x2010 ... 0x201F,
			 0x2032 ... 0x2037:
			return true
			
		default:
			return false
		}
	}
}

//func countOfCharacter(character: Character) -> (utf16: Int, twitter: Int) {
//	
////	character.utf16.count
//	
//	
//}
