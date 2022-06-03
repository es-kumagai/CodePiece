//
//  UserEntities.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct UserEntities : Decodable, Sendable {
	
	public var url: URLEntity?
	public var description: DescriptionEntity
	
	public struct URLEntity : Decodable, Sendable {
		
		public var urls: [URLInfo]
	}
	
	public struct DescriptionEntity : Decodable, Sendable {
		
		public var urls: [URLInfo]
	}
}
