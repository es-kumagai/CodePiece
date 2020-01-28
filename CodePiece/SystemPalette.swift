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
