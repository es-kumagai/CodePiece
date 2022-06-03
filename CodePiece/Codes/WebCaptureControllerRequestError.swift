//
//  WebCaptureControllerRequestError.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/06/03
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension WebCaptureController.Request {
	
	enum Error : Swift.Error {
		
		case scriptEvaluationError(String)
		case failedToTakeSnapshot
		case webLoadingError(Swift.Error)
	}
}

extension WebCaptureController.Request.Error : CustomStringConvertible {

	var description: String {
		
		switch self {
			
		case .scriptEvaluationError(let message):
			return "Script evaluation error: \(message)"
			
		case .failedToTakeSnapshot:
			return "Failed to take snapshot"
			
		case .webLoadingError(let error):
			return "Web loading error: \(error)"
		}
	}
}

extension WebCaptureController.Request.Error : CustomNSError {

	var errorUserInfo: [String : Any] {
		
		[NSLocalizedDescriptionKey : description]
	}
}
