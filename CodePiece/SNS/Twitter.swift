//
//  Twitter.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/28.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

struct Twitter {
	
	enum SpecialCounting {
		
		case Media
		case HTTPUrl
		case HTTPSUrl
	}
}

extension Twitter.SpecialCounting {
	
	var length:Int {
		
		switch self {
			
		case .Media:
			return 23
			
		case .HTTPUrl:
			return 22
			
		case .HTTPSUrl:
			return 23
		}
	}
}
