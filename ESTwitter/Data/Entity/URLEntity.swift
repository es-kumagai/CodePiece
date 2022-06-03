//
//  HashtagEntity.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct URLEntity : HasIndices, Sendable {
	
	public var url: TwitterURL
	public var indices: Indices
	public var displayUrl: String
	public var expandedUrl: TwitterURL
}

extension URLEntity : EntityUnit {
	
	var displayText: String {
		
		displayUrl
	}
}

extension URLEntity : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case url
		case indices
		case displayUrl = "display_url"
		case expandedUrl = "expanded_url"
	}
}
