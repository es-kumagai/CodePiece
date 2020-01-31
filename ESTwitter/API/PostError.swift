//
//  Error.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

public enum PostError : Error {
	
	public enum State {
	
		case beforePosted
		case afterPosted
		case noPost
	}
	
	case apiError(APIError, state: State)
	case tweetError(String)
	case parseError(String, state: State)
	case internalError(String, state: State)
	case unexpectedError(Error, state: State)
}

extension PostError {
	
	init(tweetError error: SwifterError) {
		
		switch error.kind {
			
		case .urlResponseError:
			
			switch SwifterError.Response(fromMessage: error.message) {
				
			case .some(let response):
				self = .tweetError(response.message)
				
			case .none:
				self = .tweetError(error.message)
			}
			
		default:
			self = .tweetError(error.message)
		}
	}
}

// MARK: - Swifter
internal extension SwifterError {
	
	struct Response: Decodable {
		
		var code: Int
		var message: String
	}
}

internal extension SwifterError.Response {
	
	init?(fromMessage message: String) {
	
		let components = message.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
		
		guard let rawBody = components.last else {
			
			return nil
		}
		
		typealias ResponseJson = [String : [SwifterError.Response]]
		
//		let body = "{\(rawBody.trimmingCharacters(in: .whitespaces))}"
		let body = rawBody
			.replacingOccurrences(of: "Response:", with: "")
			.trimmingCharacters(in: .whitespaces)
		
//		let body = """
//		{
//			"code": 220,
//			"message": "DUMMY"
//		}
//		"""
		
		guard
			let bodyData = body.data(using: .utf8),
			let jsonObject = try? JSONDecoder().decode(ResponseJson.self, from: bodyData),
			let responses = jsonObject["errors"],
			let response = responses.first
			else {
			
			return nil
		}
		
		self = response
	}

	init?(error: SwifterError) {
		
		guard case .urlResponseError = error.kind else {
			
			return nil
		}
		
		self.init(fromMessage: error.message)
	}
}
