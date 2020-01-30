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
	
		case Twitter
		case Gist
	}
}

extension SNSController.Service : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .Twitter:
			return "Twitter"
			
		case .Gist:
			return "Gist"
		}
	}
}
