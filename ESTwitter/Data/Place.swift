//
//  Place.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct Place {
	
	public var attributes: [String : String]
	public var boundingBox: BoundingBox
	public var containedWithin: [String]
	public var country: String
	public var countryCode: String
	public var fullName: String
	public var id:String
	public var name: String
	public var placeType: String
	public var url: TwitterUrl
}

extension Place : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case attributes
		case boundingBox = "bounding_box"
		case containedWithin = "contained_within"
		case country
		case countryCode = "country_code"
		case fullName = "full_name"
		case id
		case name
		case placeType = "place_type"
		case url
	}
}
