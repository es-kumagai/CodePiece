//
//  Geometory.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/31.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

public struct Geometory : Decodable {
	
	var type: String
	var coordinates: CoordinatesElement
}

extension Geometory {

	enum CodingKeys : CodingKey {

		case type
		case coordinates
	}

	public init(from decoder: Decoder) throws {

		let container = try decoder.container(keyedBy: CodingKeys.self)
		let array = try container.decode([Double].self, forKey: .coordinates)

		type = try container.decode(String.self, forKey: .type)
		coordinates = CoordinatesElement(latitude: array[1], longitude: array[0])
	}
}
