//
//  SystemPalette.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 3/18/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

extension NSFont {
	
	static let textFont = SystemFont.forText.font(size: 13.0)!
	static let codeFont = SystemFont.forCode.font(size: 14.0)!
}

private enum SystemFont : Sendable {
	
	case forText
	case forCode
	
	func font(size: CGFloat) -> NSFont? {
		
		switch self {
			
		case .forText:
			return NSFont.systemFont(ofSize: size)
			
		case .forCode:
			return NSFont(name: "SourceHanCodeJP-Regular", size: size)
		}
	}
}
