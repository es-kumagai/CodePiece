//
//  Media.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/15.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct Media : Sendable {
	
	public var id: UInt64
	public var idString: String
	public var size: Int
	public var image: Image
}

extension Media {
	
	public struct Image : Sendable {
		
		public var width: Int
		public var height: Int
		public var type: String
	}
}

extension Media : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case id = "media_id"
		case idString = "media_id_string"
		case size
		case image
	}
}

extension Media.Image : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case width = "w"
		case height = "h"
		case type = "image_type"
	}
}
