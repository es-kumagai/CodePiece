//
//  StatusEntities.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

extension Status {
	
	public struct Entities {
				
		public var urls:[URL]
		public var hashtags:[HashtagEntity]
		public var userMenthions:[String]
	}
}

extension Status.Entities : Decodable {
	
	public static func decode(e: Extractor) throws -> Status.Entities {
		
		return try build(Status.Entities.init)(
			
			e <|| "urls",
			e <|| "hashtags",
			e <|| "user_mentions"
		)
	}
}
