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
		
		return try build(Place.init)(
		
			e <|-| "attributes",
			e <| "bounding_box",
			e <|| "contained_within",
			e <| "country",
			e <| "country_code",
			e <| "full_name",
			e <| "id",
			e <| "name",
			e <| "place_type",
			e <| "url"
		)
	}
}
