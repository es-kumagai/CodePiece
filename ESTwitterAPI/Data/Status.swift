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

	private func applyAttribute(text: NSMutableAttributedString, urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor) {
		
		if let entities = entities {

			func setLinkAttributeWithURL(url: NSURL, color: NSColor, range: NSRange) {
			
				text.addAttribute(NSLinkAttributeName, value: url, range: range)
				text.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
				text.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleNone.rawValue, range: range)
				text.addAttribute(NSUnderlineColorAttributeName, value: NSColor.clearColor(), range: range)
			}
			
			entities.urls?.forEach {

				setLinkAttributeWithURL($0.expandedUrl.url!, color: urlColor, range: NSRange($0.indices))
			}
			
			entities.hashtags?.forEach {
				
				setLinkAttributeWithURL($0.value.url, color: hashtagColor, range: NSRange($0.indices))
			}
			
			entities.media?.forEach {
				
				setLinkAttributeWithURL($0.url.url!, color: urlColor, range: NSRange($0.indices))
			}
			
			entities.userMenthions?.forEach {
				
				setLinkAttributeWithURL($0.url, color: mentionColor, range: NSRange($0.indices))
			}
		}
		
	}

	public func attributedText(urlColor urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor) -> NSAttributedString {
	
		let text = NSMutableAttributedString(string: self.text)
		
		applyAttribute(text, urlColor: urlColor, hashtagColor: hashtagColor, mentionColor: mentionColor)
		
		return text.copy() as! NSAttributedString
	}
	
	public func attributedText(urlColor urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor, @noescape tweak: (NSMutableAttributedString) throws -> Void) rethrows -> NSAttributedString {
		
		let text = NSMutableAttributedString(string: self.text)
		
		// first, apply attributes to entire text.
		try tweak(text)
		
		// then, apply attributes to parts of text.
		applyAttribute(text, urlColor: urlColor, hashtagColor: hashtagColor, mentionColor: mentionColor)
		
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
