//
//  Colors.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

enum SystemColor {
	
	case TextForAuthenticated
	case TextForAuthenticatedWithNoTalken
	case TextForNotAuthenticated
	
	case ErrorColor
	
	var color:NSColor {
		
		switch self {
			
		case .TextForAuthenticated:
			return NSColor(red:0.210, green:0.355, blue:0.827, alpha:1.000)
			
		case .TextForAuthenticatedWithNoTalken:
			return NSColor(red:0.770, green:0.549, blue:0.045, alpha:1.000)

		case .TextForNotAuthenticated:
			return NSColor(red:0.600, green:0.600, blue:0.600, alpha:1.000)
			
		case .ErrorColor:
			return NSColor(red:0.961, green:0.271, blue:0.090, alpha:1.000)
		}
	}
}
