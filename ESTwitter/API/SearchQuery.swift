//
//  SearchQuery.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2021/08/12.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension API {
	
	public struct SearchQuery : Sendable {

		var words: [String]

		public init() {
		
			words = []
		}
	}
}

public extension API.SearchQuery {
	
	static let maxLength = 500
		
	init<WORD: StringProtocol>(_ word: WORD) {
		
		self.init()
		
		append(word)
	}
	
	init<WORDS: Sequence>(words: WORDS) where WORDS.Element : StringProtocol {
		
		self.init()
		
		words.forEach { append($0) }
	}

	var queryString: String {
		
		let escapedWords = words
			.map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! }
			.enumerated()
			.map { $0 == 0 ? $1 : " \($1)" }

		return escapedWords.reduce(into: "") { result, word in
		
			guard result.count + word.count < Self.maxLength else {
				
				return
			}
			
			result += word
		}
	}
	
	var urlQueryString: String {
		
		let queryString = self.queryString
		
		return queryString.replacingOccurrences(of: " ", with: "%20", options: .literal, range: queryString.startIndex ..< queryString.endIndex)
	}
	
	var isEmpty: Bool {
		
		words.allSatisfy(\.isEmpty)
	}
	
	mutating func append<WORD: StringProtocol>(_ word: WORD, wordOperator: String? = nil, wordPrefix: String = "", inQuotationMarks: Bool = true) {
	
		if !words.isEmpty, let wordOperator = wordOperator {
		
			append(wordOperator, inQuotationMarks: false)
		}
		
		switch inQuotationMarks {

		case true:
			words.append("\(wordPrefix)\"\(word)\"")
			
		case false:
			words.append("\(wordPrefix)\(word)")
		}
	}
	
	mutating func and<WORD: StringProtocol>(_ word: WORD) {
		
		append(word, wordOperator: "AND")
	}
	
	mutating func or<WORD: StringProtocol>(_ word: WORD) {
		
		append(word, wordOperator: "OR")
	}
	
	mutating func exclude<WORD: StringProtocol>(_ word: WORD) {
		
		append(word, wordPrefix: "-")
	}
	
	mutating func and(_ user: User) {
		
		append("from:\(user.screenName)", wordOperator: "AND", inQuotationMarks: false)
	}
	
	mutating func or(_ user: User) {
		
		append("from:\(user.screenName)", wordOperator: "OR", inQuotationMarks: false)
	}
	
	mutating func exclude(_ user: User) {
		
		append("from:\(user.screenName)", wordPrefix: "-", inQuotationMarks: false)
	}
}

extension API.SearchQuery : Hashable {
	
}

extension API.SearchQuery : CustomDebugStringConvertible {
	
	public var debugDescription: String {
		
		words.joined(separator: " ")
	}
}
