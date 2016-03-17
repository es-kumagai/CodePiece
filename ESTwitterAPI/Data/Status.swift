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
	public var retweetedStatus:RetweetedStatus?
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

extension Status {
	
	public var isRetweetedTweet: Bool {
		
		return self.retweetedStatus.isExists
	}
	
	public var attributedText: NSAttributedString {
		
		let text = NSMutableAttributedString(string: self.text)

		// FIXME: ツイート内にリンクが記載されていても、それが entities に記録されるわけではない様子…
//		entities?.urls?.forEach {
//			
//			text.addAttribute(NSLinkAttributeName, value: $0.expandedUrl.url!, range: NSRange($0.indices))
//		}
		
		return text.copy() as! NSAttributedString
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
		
		return try Status(
			
			coordinates: e.valueOptional("coordinates"),
			favorited: e.value("favorited"),
			createdAt: e.value("created_at"),
			truncated: e.value("truncated"),
			idStr: e.value("id_str"),
			entities: e.valueOptional("entities"),
			inReplyTo: InReplyTo.decodeOptional(e),
			text: e.value("text"),
			contributors: e.valueOptional("contributors"),
			retweetCount: e.value("retweet_count"),
			id: e.value("id"),
			geo: e.valueOptional("geo"),
			retweeted: e.value("retweeted"),
			retweetedStatus: e.valueOptional("retweeted_status"),
			place: e.valueOptional("place"),
			possiblySensitive: e.valueOptional("possibly_sensitive"),
			user: e.value("user"),
			lang: e.valueOptional("lang"),
			source: e.value("source")
		)
	}
}
