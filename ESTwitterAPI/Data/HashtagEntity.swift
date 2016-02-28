//
//  HashtagEntity.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct HashtagEntity {
	
	public var value:Hashtag
	public var indices:Indices
}

extension HashtagEntity : Decodable {
	
	public static func decode(e: Extractor) throws -> HashtagEntity {
		
		return try HashtagEntity(
			
			value: e.value("text"),
			indices: e.value("indices")
		)
	}
}
