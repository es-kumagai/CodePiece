//
//  Coordinate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct Coordinate {
	
	var items: [Item]
	
	public struct Item {

		public var latitude: Double
		public var longitude: Double
	}
}

extension Coordinate : Decodable {

	public static func decode(e: Extractor) throws -> Coordinate {
		
		return try Coordinate(items: decodeArray(e.rawValue))
	}
}

extension Coordinate.Item : Decodable {

	public static func decode(e: Extractor) throws -> Coordinate.Item {

		let array = try decodeArray(e.rawValue) as [Double]

		guard array.count == 2, case let (latitude, longitude) = (array[0], array[1]) else {
			
			throw DecodeError.TypeMismatch(expected: "\(Coordinate.self)", actual: "\(array)", keyPath: nil)
		}
		
		return Coordinate.Item(latitude: latitude, longitude: longitude)
	}
}