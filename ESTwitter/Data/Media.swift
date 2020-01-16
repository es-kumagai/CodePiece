//
//  Media.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/15.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

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

public struct MediaEntity : HasIndices {
	
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
		
		return try Media(
		
			id: e.value("media_id"),
			idString: e.value("media_id_string"),
			size: e.value("size"),
			image: e.value("image")
		)
	}
}

extension Media.Image : Decodable {
	
	public static func decode(e: Extractor) throws -> Media.Image {
		
		return try Media.Image(
		
			width: e.value("w"),
			height: e.value("h"),
			type: e.value("image_type")
		)
	}
}

extension MediaEntity : Decodable {

	public static func decode(e: Extractor) throws -> MediaEntity {
		
		return try MediaEntity(
		
			idStr: e.value("id_str"),
			mediaUrlHttps: e.value("media_url_https"),
			expandedUrl: e.value("expanded_url"),
			id: e.value("id"),
			sizes: e.dictionary("sizes"),
			displayUrl: e.value("display_url"),
			type: e.value("type"),
			indices: e.value("indices"),
			mediaUrl: e.value("media_url"),
			url: e.value("url")
		)
	}
}

extension MediaEntity.Size : Decodable {
	
	public static func decode(e: Extractor) throws -> MediaEntity.Size {
		
		return try MediaEntity.Size(
			
			width: e.value("w"),
			height: e.value("h"),
			resize: e.value("resize")
		)
	}
}
