//
//  HashtagEntity.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct HashtagEntity {
	
	public var value: Hashtag
	public var indices: Indices
}

extension HashtagEntity : EntityUnit {
	
	var displayText: String {
		
		value.value
	}
}

extension HashtagEntity : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case text
		case indices
	}
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		value = try Hashtag(container.decode(String.self, forKey: .text))
		indices = try container.decode(Indices.self, forKey: .indices)
	}
}
