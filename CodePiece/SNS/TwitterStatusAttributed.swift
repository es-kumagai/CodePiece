//
//  TwitterStatusAttributed.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 3/18/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESTwitter

extension Status {
	
	public func attributedText() -> NSAttributedString {
		
		return attributedText(urlColor: systemPalette.urlColor, hashtagColor: systemPalette.hashtagColor, mentionColor: systemPalette.mentionColor)
	}
	
	public func attributedText(@noescape tweak: (NSMutableAttributedString) throws -> Void) rethrows -> NSAttributedString {
		
		return try attributedText(urlColor: systemPalette.urlColor, hashtagColor: systemPalette.hashtagColor, mentionColor: systemPalette.mentionColor, tweak: tweak)
	}
}