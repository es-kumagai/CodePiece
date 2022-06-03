//
//  WebCaptureControllerCaptureError.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/06/03
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension WebCaptureController.CaptureError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .responseError(let error):
			return error.localizedDescription
		}
	}
}

extension WebCaptureController.CaptureError : CustomNSError {
	
	var errorUserInfo: [String : Any] {

		[NSLocalizedDescriptionKey : description]
	}
}
