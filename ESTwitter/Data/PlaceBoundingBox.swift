//
//  PlaceBoundingBox.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

extension Place {

	public struct BoundingBox : Decodable, Sendable {
	
		var coordinates: [Polygon]
		var type: String
	}
}
