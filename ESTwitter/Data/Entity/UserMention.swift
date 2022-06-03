//
//  UserMention.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Foundation

public struct UserMention : Decodable, HasIndices, Sendable {
	
	public var id: UInt64
	public var idStr: String
	public var name: String
	public var screenName: String
	public var indices: Indices
	
	public enum CodingKeys : String, CodingKey {
		
		case id
		case idStr = "id_str"
		case name
		case screenName = "screen_name"
		case indices
	}
}

extension UserMention : EntityUnit {

	var displayText: String {
		
		description
	}
}

extension UserMention {
	
	var url: TwitterURL {
		
		TwitterURL(rawValue: "https://twitter.com/\(screenName)")
	}
}

extension UserMention : CustomStringConvertible {

	public var description: String {
		
		return "@\(screenName)"
	}
}
