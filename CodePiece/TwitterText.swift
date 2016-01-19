//
//  TwitterText.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Foundation

protocol TwitterTextType {
	
	var twitterText: String { get }
	
	mutating func clearTwitterText()
}

struct TwitterTextPart {

	enum Type {
	
		case ScreenName
	}
	
	var text: String
	var type: Type
	var range: Range<String.Index>
}

extension TwitterTextType {
	
	var includedScreenNames: [TwitterTextPart] {
		
		let expression = try! NSRegularExpression(pattern: "(?<!\\w)@\\w+\\b", options: NSRegularExpressionOptions(rawValue: 0))
		
		let text = self.twitterText
		let options = NSMatchingOptions(rawValue: 0)
		let range = NSMakeRange(0, text.utf16.count)
		
		return expression.matchesInString(text, options: options, range: range).reduce([TwitterTextPart]()) { parts, match in

			let startIndex = text.startIndex.advancedBy(match.range.location + 1)
			let endIndex = startIndex.advancedBy(match.range.length - 1)
			let range = startIndex ..< endIndex
			
			let screenName = text[startIndex ..< endIndex]
			let textPart = TwitterTextPart(text: screenName, type: .ScreenName, range: range)
			
			return parts + [textPart]
		}
	}
	
	func containsScreenName(screenName: String) -> Bool {
		
		return includedScreenNames.contains { $0.text == screenName }
	}
	
	var isReplyAddressOnly: Bool {
		
		let expression = try! NSRegularExpression(pattern: "^@\\w+$", options: NSRegularExpressionOptions(rawValue: 0))
		
		let text = self.twitterText
		let options = NSMatchingOptions(rawValue: 0)
		let range = NSMakeRange(0, text.utf16.count)
		
		return expression.firstMatchInString(text, options: options, range: range).isExists
	}
}