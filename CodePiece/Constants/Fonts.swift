//
//  Fonts.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/26.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

enum SystemFont {
	
	case FontForCode
	
	func fontWithSize(size:CGFloat) -> NSFont? {
		
		switch self {
			
		case .FontForCode:
			return NSFont(name: "SourceHanCodeJP-Regular", size: size)
		}
	}
}
