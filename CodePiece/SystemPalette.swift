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
	
	let textFont = SystemFont.forText.font(withSize: 13.0)!
	let codeFont = SystemFont.forCode.font(withSize: 14.0)!
	
	let textColor = #colorLiteral(red: 0.208, green: 0.333, blue: 0.416, alpha: 1.000)
	let urlColor = #colorLiteral(red: 0.26, green: 0.47, blue: 0.96, alpha: 1.0)
	let hashtagColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.733, alpha: 1.0)
	let mentionColor = #colorLiteral(red: 0.0, green: 0.412, blue: 0.851, alpha: 1.0)
	
	fileprivate init() {
		
	}
}

private enum SystemFont {
	
	case forText
	case forCode
	
	func font(withSize size:CGFloat) -> NSFont? {
		
		switch self {
			
		case .forText:
			return NSFont.systemFont(ofSize: size)
			
		case .forCode:
			return NSFont(name: "SourceHanCodeJP-Regular", size: size)
		}
	}
}
