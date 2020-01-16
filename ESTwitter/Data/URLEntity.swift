//
//  HashtagEntity.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct URLEntity : HasIndices {
	
	public var url: URL
	public var indices: Indices
	public var displayUrl: String
	public var expandedUrl: URL
}

extension URLEntity : Decodable {
	
	public static func decode(e: Extractor) throws -> URLEntity {
		
		return try URLEntity(
			
			url: e.value("url"),
			indices: e.value("indices"),
			displayUrl: e.value("display_url"),
			expandedUrl: e.value("expanded_url")
		)
	}
}
