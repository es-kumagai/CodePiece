//
//  APIError.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

public enum APIError : Error {
	
	case notReady
	case responseError(code: Int, message: String)
	case operationError(String)
	case offline(String)
	case unexpected(Error)
}

internal extension APIError {

	init(from error: SwifterError) {
		
		if case .urlResponseError = error.kind, let response = SwifterError.Response(fromMessage: error.message) {

			self = .responseError(code: response.code, message: response.message)
		}
		else {
			
			self = .unexpected(error)
		}
	}
	
	init(from error: NSError) {
		
		switch error.code {
			
		case -1009:
			self = .offline(error.localizedDescription)
			
		default:
			self = .unexpected(error)
		}
	}
}

extension APIError : CustomStringConvertible {
	
	public var description: String {
		
		switch self {
			
		case .notReady:
			return "API is not ready."

		case .responseError(_, let message):
			return message
			
		case .operationError(let message):
			return message
			
		case .offline(let message):
			return message
			
		case .unexpected(let error):
			return "Unexpected error: \(error)"
		}
	}
}
