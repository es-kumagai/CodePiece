//
//  Status.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki
import Swim

public enum RetweetedStatus {
	
	indirect case Value(Status)
}

public struct Status {
	
	public var coordinates:CoordinatesBox?
	public var favorited:Bool
	public var createdAt:Date
	public var truncated:Bool
	public var idStr:String
	public var entities:Entities?
	public var inReplyTo:InReplyTo?
	public var text:String
	public var contributors:String?
	public var retweetCount:Int
	public var id:UInt64
	public var geo:CoordinatesBox?
	public var retweeted:Bool
	internal var retweetedStatus:RetweetedStatus?
	public var place:Place?
	public var possiblySensitive: Bool?
	public var user:User
	public var lang:String?
	public var source:String
}

extension RetweetedStatus {

	public var status:Status {
		
		switch self {
			
		case .Value(let value):
			return value
		}
	}
}

extension RetweetedStatus : Decodable {
	
	public static func decode(e: Extractor) throws -> RetweetedStatus {
		
		return try RetweetedStatus.Value(Status.decode(e))
	}
}

extension SequenceType where Generator.Element == Status {

	public func orderByNewCreationDate() -> [Generator.Element] {
	
		return self.sort { $0.0.createdAt > $0.1.createdAt }
	}
	
	public func excludeRetweets() -> [Generator.Element] {
		
		return self.filter { !$0.retweeted }
	}
	
	public func originalTweetAtFirst() -> Generator.Element? {
		
		guard let found = self.findElement({$0.retweeted}) else {
			
			return nil
		}
		
		return found.element
	}
}

extension Status : Decodable {
	
	public static func decode(e: Extractor) throws -> Status {
		
		return try build(Status.init)(
			
			e <|? "coordinates",
			e <| "favorited",
			e <| "created_at",
			e <| "truncated",
			e <| "id_str",
			e <|? "entities",
			InReplyTo.decodeOptional(e),
			e <| "text",
			e <|? "contributors",
			e <| "retweet_count",
			e <| "id",
			e <|? "geo",
			e <| "retweeted",
			e <|? "retweeted_status",
			e <|? "place",
			e <|? "possibly_sensitive",
			e <| "user",
			e <|? "lang",
			e <| "source"
		)
	}
}
