//
//  TwitterStatusAttributed.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 3/18/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

extension Status {
	
	public func attributedText() -> NSAttributedString {
		
		return attributedText(urlColor: .urlColor, hashtagColor: .hashtagColor, mentionColor: .mentionColor)
	}
	
	public func attributedText(customizeExpression expression: (NSMutableAttributedString) throws -> Void) rethrows -> NSAttributedString {
		
		return try attributedText(urlColor: .urlColor, hashtagColor: .hashtagColor, mentionColor: .mentionColor, customizeExpression: expression)
	}
}
