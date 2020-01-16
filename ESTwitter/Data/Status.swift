//
//  Status.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

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
		
		text.beginEditing()
		
		defer {
			
			text.endEditing()
		}
		
		if let entities = entities {

			let baseAttributes = { () -> [String : AnyObject] in
				
				var results = [String : AnyObject]()
				
				text.enumerateAttributesInRange(NSMakeRange(0, text.length), options: []) { (attributes: [String : AnyObject], range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
					
					for (name, value) in attributes {
						
						results[name] = value
					}
				}
				
				return results
			}()
			
			struct LinkItem : HasIndices {
			
				var indices: Indices
				var color: NSColor
				var displayText: String
				var link: NSURL
				
				init(_ entity: URLEntity, color: NSColor) {
					
					self.indices = entity.indices
					self.color = color
					self.displayText = entity.displayUrl
					self.link = entity.expandedUrl.url!
				}
				
				init(_ entity: HashtagEntity, color: NSColor) {
					
					self.indices = entity.indices
					self.color = color
					self.displayText = entity.value.description
					self.link = entity.value.url
				}
				
				init(_ entity: MediaEntity, color: NSColor) {
					
					self.indices = entity.indices
					self.color = color
					self.displayText = entity.displayUrl
					self.link = entity.expandedUrl.url!
				}
				
				init(_ entity: UserMention, color: NSColor) {
					
					self.indices = entity.indices
					self.color = color
					self.displayText = entity.description
					self.link = entity.url
				}
				
				func attributedTextWithBaseAttributes(baseAttributes: [String : AnyObject]) -> NSAttributedString {
				
					return NSAttributedString(string: displayText, attributes: attributesWithBaseAttributes(baseAttributes))
				}
				
				var range: NSRange {
					
					return NSRange(indices)
				}
				
				func attributesWithBaseAttributes(baseAttributes: [String : AnyObject]) -> [String : AnyObject] {
					
					var results = baseAttributes
					
					results[NSLinkAttributeName] = link
					results[NSForegroundColorAttributeName] = color
					results[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleNone.rawValue
					results[NSUnderlineColorAttributeName] = NSColor.clearColor()
					
					return results
				}
			}

			let linkItems = FlattenCollection([
				
				entities.urls?.map { LinkItem.init($0, color: urlColor) },
				entities.hashtags?.map { LinkItem.init($0, color: hashtagColor) },
				entities.media?.map { LinkItem.init($0, color: urlColor) },
				entities.userMenthions?.map { LinkItem.init($0, color: mentionColor) }
				]
				.flatMap { $0 })
			
			for item in linkItems.sortedByIndicesDescend {
				
				text.replaceCharactersInRange(item.range, withAttributedString: item.attributedTextWithBaseAttributes(baseAttributes))
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
