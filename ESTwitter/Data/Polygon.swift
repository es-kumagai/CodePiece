//
//  Polygon.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/31.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

public struct Polygon : Sendable {
	
	var points: [CoordinatesElement]
}

extension Polygon : Decodable {
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.singleValueContainer()
		let array = try container.decode([CoordinatesElement].self)
		
		guard array.count == 4 else {
			
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Incorrect polygon value.")
		}

		points = array
	}
}
