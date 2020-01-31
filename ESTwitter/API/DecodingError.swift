//
//  DecodingError.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

extension DecodingError : CustomStringConvertible {
	
	public var description: String {
		
		let prefix = localizedDescription

		func string(from context: DecodingError.Context) -> String {
			
			let message = context.debugDescription
			let pathInfo = context.codingPath
				.map { $0.stringValue }
				.joined(separator: ".")

			switch pathInfo.isEmpty {
				
			case true:
				return "\(message)"

			case false:
				return "\(message) (\(pathInfo))"
			}
		}
		
		switch self {
			
		case let .typeMismatch(_, context):
			return "\(prefix) \(string(from: context))"
			
		case let .valueNotFound(_, context):
			return "\(prefix) \(string(from: context))"

		case let .keyNotFound(_, context):
			return "\(prefix) \(string(from: context))"

		case let .dataCorrupted(context):
			return "\(prefix) \(string(from: context))"

		@unknown default:
			return "\(prefix)"
		}
	}
}
