//
//  Media.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/15.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

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

extension MediaEntity : EntityUnit {
	
}

extension MediaEntity : Decodable {

	enum CodingKeys : String, CodingKey {
	
		case idStr = "id_str"
		case mediaUrlHttps = "media_url_https"
		case expandedUrl = "expanded_url"
		case id
		case sizes
		case displayUrl = "display_url"
		case type
		case indices
		case mediaUrl = "media_url"
		case url
	}
}

extension MediaEntity.Size : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case width = "w"
		case height = "h"
		case resize
	}
}
