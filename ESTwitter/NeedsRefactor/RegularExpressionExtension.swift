//
//  RegularExpressionExtension.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/02/09.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension NSRegularExpression {

	func replaceAllMatches(in text: NSMutableAttributedString, options: NSRegularExpression.MatchingOptions = [], with replacement: String) {
	
		for  match in matches(in: text.string, options: options, range: NSRange(location: 0, length: text.string.count)).reversed() {
			
			text.replaceCharacters(in: match.range, with: replacement)
		}
	}
	
	func replaceAllMatches(in text: NSMutableAttributedString, options: NSRegularExpression.MatchingOptions = [], with replacement: NSAttributedString) {
		
		for  match in matches(in: text.string, options: options, range: NSRange(location: 0, length: text.string.count)).reversed() {
			
			text.replaceCharacters(in: match.range, with: replacement)
		}
	}
}
