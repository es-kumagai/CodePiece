//
//  DecodingError.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swim

extension DecodingError : CustomStringConvertible {
	
	public var description: String {
		
		switch self {
			
		case let .typeMismatch(_, context):
			return "\(context)"
			
		case let .valueNotFound(_, context):
			return "\(context)"

		case let .keyNotFound(_, context):
			return "\(context)"

		case let .dataCorrupted(context):
			return "\(context)"

		@unknown default:
			return localizedDescription
		}
	}
}

extension DecodingError.Context : CustomStringConvertible {
	
	@StringConcat
	public var description: String {
		
		debugDescription

		if !codingPath.isEmpty {

			" ("
			codingPath
				.map { $0.stringValue }
				.joined(separator: ".")
			")"
		}
		
		if let error = underlyingError {

			" "
			error.localizedDescription
		}
	}
}
