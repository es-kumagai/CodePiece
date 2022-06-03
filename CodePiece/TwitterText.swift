//
//  TwitterText.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Foundation

@MainActor
protocol TwitterTextType {
	
	var twitterText: String { get }
	
	mutating func clearTwitterText()
}

struct TwitterTextPart {

	@available(*, unavailable, renamed: "Kind")
	enum `Type` {}
	
	enum Kind {
	
		case ScreenName
	}
	
	var text: String
	var type: Kind
	var range: Range<String.Index>
}

extension TwitterTextType {
	
	var includedScreenNames: [TwitterTextPart] {
		
		let expression = try! NSRegularExpression(pattern: "(?<!\\w)@\\w+\\b", options: [])
		
		let text = twitterText
		let options = NSRegularExpression.MatchingOptions(rawValue: 0)
		let range = NSMakeRange(0, text.utf16.count)
		
		return expression.matches(in: text, options: options, range: range).reduce([TwitterTextPart]()) { parts, match in

			let startIndex = text.index(text.startIndex, offsetBy: match.range.location + 1)
			let endIndex = text.index(startIndex, offsetBy: match.range.length - 1)
			let range = startIndex ..< endIndex
			
			let screenName = text[startIndex ..< endIndex]
			let textPart = TwitterTextPart(text: String(screenName), type: .ScreenName, range: range)
			
			return parts + [textPart]
		}
	}
	
	func containsScreenName(screenName: String) -> Bool {
		
		return includedScreenNames.contains { $0.text == screenName }
	}
	
	var isReplyAddressOnly: Bool {
		
		let expression = try! NSRegularExpression(pattern: "^@\\w+$", options: [])
		
		let text = twitterText
		let options = NSRegularExpression.MatchingOptions(rawValue: 0)
		let range = NSMakeRange(0, text.utf16.count)
		
		return expression.firstMatch(in: text, options: options, range: range) != nil
	}
}
