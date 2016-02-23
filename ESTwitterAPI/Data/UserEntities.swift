//
//  UserEntities.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct UserEntities {
	
	public var urls:URLEntity?
	public var description:DescriptionEntity
	
	public struct URLEntity {
		
		public var urls:[URLInfo]
	}
	
	public struct DescriptionEntity {
		
		public var urls:[URLInfo]
	}
}

extension UserEntities : Decodable {

	public static func decode(e: Extractor) throws -> UserEntities {
		
		return try UserEntities(
		
			urls: e.valueOptional("url"),
			description: e.value("description")
		)
	}
}

extension UserEntities.URLEntity : Decodable {
	
	public static func decode(e: Extractor) throws -> UserEntities.URLEntity {
		
		return try UserEntities.URLEntity(
		
			urls: e.array("urls")
		)
	}
}

extension UserEntities.DescriptionEntity : Decodable {
	
	public static func decode(e: Extractor) throws -> UserEntities.DescriptionEntity {
		
		return try UserEntities.DescriptionEntity(
			
			urls: e.array("urls")
		)
	}
}
