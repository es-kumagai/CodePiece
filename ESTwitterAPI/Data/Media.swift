//
//  Media.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/15.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct Media {
	
	public var id: UInt64
	public var idString: String
	public var size: Int
	public var image: Image
	
	public struct Image {
		
		public var width: Int
		public var height: Int
		public var type: String
	}
}

extension Media : Decodable {
	
	public static func decode(e: Extractor) throws -> Media {
		
		return try build(Media.init)(
		
			e <| "media_id",
			e <| "media_id_string",
			e <| "size",
			e <| "image"
		)
	}
}

extension Media.Image : Decodable {
	
	public static func decode(e: Extractor) throws -> Media.Image {
		
		return try build(Media.Image.init)(
		
			e <| "w",
			e <| "h",
			e <| "image_type"
		)
	}
}
