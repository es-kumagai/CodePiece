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
		
		case media
		case httpUrl
		case httpsUrl
	}
}

extension Twitter.SpecialCounting {
	
	var length: Int {
		
		switch self {
			
		case .media:
			return 23
			
		case .httpUrl:
			return 22
			
		case .httpsUrl:
			return 23
		}
	}
}
