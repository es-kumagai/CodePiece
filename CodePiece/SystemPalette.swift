//
//  SystemPalette.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 3/18/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

let systemPalette = SystemPalette()

struct SystemPalette {
	
	let textFont: NSFont! = SystemFont.FontForText.fontWithSize(13.0)
	let codeFont: NSFont! = SystemFont.FontForCode.fontWithSize(14.0)
	
	let textColor = [#Color(colorLiteralRed: 0.208, green: 0.333, blue: 0.416, alpha: 1.000)#]
	let urlColor = [#Color(colorLiteralRed: 0.26, green: 0.47, blue: 0.96, alpha: 1.0)#]
	let hashtagColor = [#Color(colorLiteralRed: 0.6, green: 0.6, blue: 0.733, alpha: 1.0)#]
	let mentionColor = [#Color(colorLiteralRed: 0.0, green: 0.412, blue: 0.851, alpha: 1.0)#]
	
	private init() {
		
	}
}

private enum SystemFont {
	
	case FontForText
	case FontForCode
	
	func fontWithSize(size:CGFloat) -> NSFont? {
		
		switch self {
			
		case .FontForText:
			return NSFont.systemFontOfSize(size)
			
		case .FontForCode:
			return NSFont(name: "SourceHanCodeJP-Regular", size: size)
		}
	}
}
