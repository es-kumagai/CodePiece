//
//  Polygon.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/31.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

public struct Polygon {
	
	var points: [CoordinatesElement]
}

extension Polygon : Decodable {
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.singleValueContainer()

		points = try container.decode([CoordinatesElement].self)
	}
}
