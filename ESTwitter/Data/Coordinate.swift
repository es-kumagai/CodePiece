//
//  Coordinate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct CoordinatesElement {

	var latitude: Double
	var longitude: Double
}

public struct GeoCoordinatesElement {

	var latitude: Double
	var longitude: Double
}

public struct Coordinates {
	
	var coordinates: CoordinatesElement
	var type: String
}

extension Coordinates : Decodable {
	
}

extension CoordinatesElement : Decodable {

	public init(from decoder: Decoder) throws {

		let container = try decoder.singleValueContainer()
		let array = try container.decode([Double].self)

		guard array.count == 2 else {
			
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot values for latitude and longitude.")
		}
		
		latitude = array[1]
		longitude = array[0]
	}
}

extension GeoCoordinatesElement : Decodable {

	public init(decoder: Decoder) throws {
	
		let container = try decoder.singleValueContainer()
		let array = try container.decode([Double].self)

		guard array.count == 2 else {
			
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot values for latitude and longitude.")
		}
		
		latitude = array[0]
		longitude = array[1]
	}
}
