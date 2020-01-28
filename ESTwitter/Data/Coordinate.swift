//
//  Coordinate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

// FIXME: 今は Twitter の JSON に合わせているけれど、わかりにくいので [Coordinate] になるようにしたい。
public struct Coordinate {
	
	var items: [Item]
	
	public struct Item {

		public var latitude: Double
		public var longitude: Double
	}
}

extension Coordinate : Decodable {

}

extension Coordinate.Item : Decodable {

	public init(from decoder: Decoder) throws {
	
		let container = try decoder.singleValueContainer()
		let array = try container.decode([Double].self)

		guard array.count == 2 else {
			
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot values for latitude and longitude.")
		}
		
		latitude = array[0]
		longitude = array[1]
	}
}
