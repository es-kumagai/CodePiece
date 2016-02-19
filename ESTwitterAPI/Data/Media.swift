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

public struct MediaEntity {
	
	public struct Size {
		
		public var width: Int
		public var height: Int
		public var resize: String
	}
	
	public var idStr: String
	public var mediaUrlHttps: URL
	public var expandedUrl: URL
	public var id: UInt64
	public var sizes: [String : Size]
	public var displayUrl: String
	public var type: String
	public var indices: Indices
	public var mediaUrl: URL
	public var url: URL
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

extension MediaEntity : Decodable {

	public static func decode(e: Extractor) throws -> MediaEntity {
		
		return try build(MediaEntity.init)(
		
			e <| "id_str",
			e <| "media_url_https",
			e <| "expanded_url",
			e <| "id",
			e <|-| "sizes",
			e <| "display_url",
			e <| "type",
			e <| "indices",
			e <| "media_url",
			e <| "url"
		)
	}
}

extension MediaEntity.Size : Decodable {
	
	public static func decode(e: Extractor) throws -> MediaEntity.Size {
		
		return try build(MediaEntity.Size.init)(
			
			e <| "w",
			e <| "h",
			e <| "resize"
		)
	}
}