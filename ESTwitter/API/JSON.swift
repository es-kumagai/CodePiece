//
//  JSON.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

extension JSON {

	enum SerializationError : Error {
		
		case invalidObject(JSON)
		case parseError(Error, JSON)
	}
	
	func serialized() throws -> Data {
		
		guard let object = self.object else {
			
			throw SerializationError.invalidObject(self)
		}
		
		do {
			
			return try JSONSerialization.data(withJSONObject: object, options: [])
		}
		catch {
			
			throw SerializationError.parseError(error, self)
		}
	}
}

extension JSON.SerializationError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .invalidObject:
			return "Invalid JSON Object."
			
		case .parseError(let error, _):
			return "Failed to parse JSON. \(error.localizedDescription)"
		}
	}
}

extension JSON.SerializationError : CustomDebugStringConvertible {
	
	var debugDescription: String {
		
		switch self {
			
		case .invalidObject(let json):
			return "\(description)\n\n\(json)"
			
		case .parseError(_, let json):
			return "F\(description)\n\n\(json)"
		}
	}
}
