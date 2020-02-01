//
//  SNSControllerService.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension SNSController {
	
	enum Service {
	
		case twitter
		case gist
	}
}

extension SNSController.Service : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .twitter:
			return "Twitter"
			
		case .gist:
			return "Gist"
		}
	}
}
