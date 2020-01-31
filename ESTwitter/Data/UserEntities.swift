//
//  UserEntities.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct UserEntities : Decodable {
	
	public var url: URLEntity?
	public var description: DescriptionEntity
	
	public struct URLEntity : Decodable {
		
		public var urls: [URLInfo]
	}
	
	public struct DescriptionEntity : Decodable {
		
		public var urls: [URLInfo]
	}
}
