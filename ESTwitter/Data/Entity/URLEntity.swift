//
//  HashtagEntity.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct URLEntity : HasIndices {
	
	public var url: TwitterUrl
	public var indices: Indices
	public var displayUrl: String
	public var expandedUrl: TwitterUrl
}

extension URLEntity : EntityUnit {
	
}

extension URLEntity : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case url
		case indices
		case displayUrl = "display_url"
		case expandedUrl = "expanded_url"
	}
}
