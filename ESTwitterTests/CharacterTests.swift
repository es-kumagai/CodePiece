//
//  CharacterTests.swift
//  ESTwitterTests
//
//  Created by Tomohiro Kumagai on 2020/02/02.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import XCTest
@testable import ESTwitter

class CharacterTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testCharactersOfUTF16() {
	
		XCTAssertEqual(UTF16Character.tpvs.rawValue, 0xFE0E)
		XCTAssertEqual(UTF16Character.epvs.rawValue, 0xFE0F)
	}
	
	func testFamilyCharacter() {
	
		let string = "👨‍👩‍👦‍👦"
		
		XCTAssertEqual((string as NSString).length, 11)
		XCTAssertEqual(string.count, 1)
		XCTAssertEqual(string.utf8.count, 25)
		XCTAssertEqual(string.utf16.count, 11)
		XCTAssertEqual(string.unicodeScalars.count, 7)
		XCTAssertEqual(string.utf8.map { $0 }, [0xF0, 0x9F, 0x91, 0xA8, 0xE2, 0x80, 0x8D, 0xF0, 0x9F, 0x91, 0xA9, 0xE2, 0x80, 0x8D, 0xF0, 0x9F, 0x91, 0xA6, 0xE2, 0x80, 0x8D, 0xF0, 0x9F, 0x91, 0xA6])
		XCTAssertEqual(string.utf16.map { $0 }, [0xD83D, 0xDC68, 0x200D, 0xD83D, 0xDC69, 0x200D, 0xD83D, 0xDC66, 0x200D, 0xD83D, 0xDC66])

		let utf8 = string.utf8.map(UTF8Character.init)
		let utf16 = string.utf16.map(UTF16Character.init)

		XCTAssertEqual(utf8.filter { $0.isUtf8LeadingByte }.count, 7)
		XCTAssertEqual(utf16.filter { $0.isEPVS }.count, 0)
		XCTAssertEqual(utf16.filter { $0.isTPVS }.count, 0)
		
		let twitter = TwitterCharacter(Character(string))
		
		XCTAssertEqual(twitter.unitCount, 11)
		XCTAssertEqual(twitter.wordCountForIndices,7)
		XCTAssertEqual(twitter.units.filter { $0.isSurrogateHight }.count, 4)
		XCTAssertEqual(twitter.units.filter { $0.isSurrogateLow }.count, 4)
		XCTAssertEqual(twitter.units.filter { $0.isZWJ }.count, 3)
	}
	
	func testReplaceFamily() {

		let string = "👨‍👩‍👧‍👧 #test"
		let attributedString = NSMutableAttributedString(string: string)
		
		let range = NSRange(location: 12, length: 5)
		let subtext = NSAttributedString(string: "@TEST", attributes: [.foregroundColor : NSColor.red])
		
		attributedString.replaceCharacters(in: range, with: subtext)
		
		XCTAssertEqual(attributedString.mutableString, "👨‍👩‍👧‍👧 @TEST")
	}

	func testReplaceExclamationHeart() {

		let string = "❣️ #test"
		let attributedString = NSMutableAttributedString(string: string)
		
		let range = NSRange(location: 3, length: 5)
		let subtext = NSAttributedString(string: "@TEST", attributes: [.foregroundColor : NSColor.red])
		
		attributedString.replaceCharacters(in: range, with: subtext)
		
		XCTAssertEqual(attributedString.mutableString, "❣️ @TEST")
	}

	func testReplaceTextedNew() {

		let string = "🆕 #test"
		let attributedString = NSMutableAttributedString(string: string)
		
		let range = NSRange(location: 3, length: 5)
		let subtext = NSAttributedString(string: "@TEST", attributes: [.foregroundColor : NSColor.red])
		
		attributedString.replaceCharacters(in: range, with: subtext)
		
		XCTAssertEqual(attributedString.mutableString, "🆕 @TEST")
	}

	func testReplaceTincleStar() {

		let string = "🌟 #test"
		let attributedString = NSMutableAttributedString(string: string)
		
		let range = NSRange(location: 3, length: 5)
		let subtext = NSAttributedString(string: "@TEST", attributes: [.foregroundColor : NSColor.red])
		
		attributedString.replaceCharacters(in: range, with: subtext)
		
		XCTAssertEqual(attributedString.mutableString, "🌟 @TEST")
	}

	func testReplaceSimpleStar() {

		let string = "⭐️ #test"
		let attributedString = NSMutableAttributedString(string: string)
		
		let range = NSRange(location: 3, length: 5)
		let subtext = NSAttributedString(string: "@TEST", attributes: [.foregroundColor : NSColor.red])
		
		attributedString.replaceCharacters(in: range, with: subtext)
		
		XCTAssertEqual(attributedString.mutableString, "⭐️ @TEST")
	}

	func testReplaceSurrogateCharacter() {

		let string = "🐲 #test"
		let attributedString = NSMutableAttributedString(string: string)
		
		let range = NSRange(location: 3, length: 5)
		let subtext = NSAttributedString(string: "@TEST", attributes: [.foregroundColor : NSColor.red])
		
		attributedString.replaceCharacters(in: range, with: subtext)
		
		XCTAssertEqual(attributedString.mutableString, "🐲 @TEST")
	}

	func testCharacterCount() {

		let s1 = "👨‍👩‍👦‍👦"	// ゼロ幅接合子
		
		XCTAssertEqual(s1.count, 1)
		XCTAssertEqual(s1.utf16.count, 11)
		XCTAssertEqual(s1.twitterCharacterView.first!.wordCountForIndices, 7)
		XCTAssertEqual(s1.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s1.twitterCharacterView.first!.isEnglish)
		XCTAssertFalse(s1.twitterCharacterView.first!.isSurrogatePair)

		let s2 = "🐲"	// サロゲートペア

		XCTAssertEqual(s2.count, 1)
		XCTAssertEqual(s2.utf16.count, 2)
		XCTAssertEqual(s2.twitterCharacterView.first!.wordCountForIndices, 1)
		XCTAssertEqual(s2.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s2.twitterCharacterView.first!.isEnglish)
		XCTAssertTrue(s2.twitterCharacterView.first!.isSurrogatePair)

		let s3 = "1️⃣"	// 絵文字シーケンス

		XCTAssertEqual(s3.count, 1)
		XCTAssertEqual(s3.utf16.count, 3)
		XCTAssertEqual(s3.twitterCharacterView.first!.wordCountForIndices, 3)
		XCTAssertEqual(s3.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s3.twitterCharacterView.first!.isEnglish)
		XCTAssertFalse(s3.twitterCharacterView.first!.isSurrogatePair)

		let s4 = "⭐️"	// 絵文字スタイル化 異体字セレクタ EPVS

		XCTAssertEqual(s4.count, 1)
		XCTAssertEqual(s4.utf16.count, 2)
		XCTAssertEqual(s4.twitterCharacterView.first!.wordCountForIndices, 2)
		XCTAssertEqual(s4.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s4.twitterCharacterView.first!.isEnglish)
		XCTAssertFalse(s4.twitterCharacterView.first!.isSurrogatePair)

		let s4_1 = "🌟"

		XCTAssertEqual(s4_1.count, 1)
		XCTAssertEqual(s4_1.utf16.count, 2)
		XCTAssertEqual(s4_1.twitterCharacterView.first!.wordCountForIndices, 2)
		XCTAssertEqual(s4_1.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s4_1.twitterCharacterView.first!.isEnglish)
		XCTAssertTrue(s4_1.twitterCharacterView.first!.isSurrogatePair)

		let s5 = "⭐︎"	// テキストスタイル化する 異体字セレクタ TPVS

		XCTAssertEqual(s5.count, 1)
		XCTAssertEqual(s5.utf16.count, 2)
		XCTAssertEqual(s5.twitterCharacterView.first!.wordCountForIndices, 2)
		XCTAssertEqual(s5.twitterCharacterView.first!.wordCountForPost, 2)
		XCTAssertFalse(s5.twitterCharacterView.first!.isEnglish)
		XCTAssertFalse(s5.twitterCharacterView.first!.isSurrogatePair)

		let s6 = "Z"
		XCTAssertEqual(s6.count , 1)
		XCTAssertEqual(s6.utf16.count, 1)
		XCTAssertEqual(s6.twitterCharacterView.first!.wordCountForIndices, 1)
		XCTAssertEqual(s6.twitterCharacterView.first!.wordCountForPost, 0.5)
		XCTAssertTrue(s6.twitterCharacterView.first!.isEnglish)
		XCTAssertFalse(s6.twitterCharacterView.first!.isSurrogatePair)

		let s7 = "☃️"
		
		print(s7, s7.utf16.map { String(format: "0x%04X", $0) })

		XCTAssertEqual(s7.count, 1)
		XCTAssertEqual(s7.utf16.count, 2)
		XCTAssertEqual(s7.twitterCharacterView.first!.wordCountForIndices, 2)
		XCTAssertEqual(s7.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s7.twitterCharacterView.first!.isEnglish)
		XCTAssertFalse(s7.twitterCharacterView.first!.isSurrogatePair)

		let s8 = "❣️"

		print(s8, s8.utf16.map { String(format: "0x%04X", $0) })

		XCTAssertEqual(s8.count, 1)
		XCTAssertEqual(s8.utf16.count, 2)
		XCTAssertEqual(s8.twitterCharacterView.first!.wordCountForIndices, 2)
		XCTAssertEqual(s8.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s8.twitterCharacterView.first!.isEnglish)
		XCTAssertFalse(s8.twitterCharacterView.first!.isSurrogatePair)

		let s9 = "🆕"

		print(s9, s9.utf16.map { String(format: "0x%04X", $0) })

		XCTAssertEqual(s9.count, 1)
		XCTAssertEqual(s9.utf16.count, 2)
		XCTAssertEqual(s9.twitterCharacterView.first!.wordCountForIndices, 1)
		XCTAssertEqual(s9.twitterCharacterView.first!.wordCountForPost, 1)
		XCTAssertFalse(s9.twitterCharacterView.first!.isEnglish)
		XCTAssertTrue(s9.twitterCharacterView.first!.isSurrogatePair)
	}

}
