//
//  Place.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct Place {
	
	public var attributes: [String:String]
	public var boundingBox: BoundingBox
	public var containedWithin: [String]
	public var country: String
	public var countryCode: String
	public var fullName: String
	public var id:String
	public var name: String
	public var placeType: String
	public var url: URL
}

extension Place : Decodable {
	
	public static func decode(e: Extractor) throws -> Place {
		
		return try Place(
		
			attributes: e.dictionary("attributes"),
			boundingBox: e.value("bounding_box"),
			containedWithin: e.array("contained_within"),
			country: e.value("country"),
			countryCode: e.value("country_code"),
			fullName: e.value("full_name"),
			id: e.value("id"),
			name: e.value("name"),
			placeType: e.value("place_type"),
			url: e.value("url")
		)
	}
}
