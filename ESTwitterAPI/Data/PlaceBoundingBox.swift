//
//  PlaceBoundingBox.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

extension Place {

	public struct BoundingBox {
	
		var coordinates: [Coordinate]
		var type: String
	}
}

extension Place.BoundingBox : Decodable {
	
	public static func decode(e: Extractor) throws -> Place.BoundingBox {
		
		return try build(Place.BoundingBox.init)(
			
			e <|| "coordinates",
			e <| "type"
		)
	}
}
