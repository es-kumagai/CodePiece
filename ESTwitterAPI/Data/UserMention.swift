//
//  UserMention.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct UserMention {
	
	public var id: UInt64
	public var idStr: String
	public var name: String
	public var screenName: String
	public var indices: Indices
}

extension UserMention : Decodable {
	
	public static func decode(e: Extractor) throws -> UserMention {
		
		return try build(UserMention.init)(
			
			e <| "id",
			e <| "id_str",
			e <| "name",
			e <| "screen_name",
			e <| "indices"
		)
	}
}