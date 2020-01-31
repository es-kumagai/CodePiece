//
//  Geometory.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/31.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

extension Status {
	
	public struct Geometory : Decodable {
	
		var type: String
		var coordinates: GeoCoordinatesElement
	}
}
