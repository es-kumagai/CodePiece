//
//  StatusEntities.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

extension Status {
	
	public struct Entities {
				
		public var urls: [URLEntity]?
		public var hashtags: [HashtagEntity]?
		public var userMentions: [UserMention]?
		public var media: [MediaEntity]?
	}
}

extension Status.Entities : Decodable {
	
	enum CodingKeys : String, CodingKey {
		
		case urls
		case hashtags
		case userMentions = "user_mentions"
		case media
	}
}
