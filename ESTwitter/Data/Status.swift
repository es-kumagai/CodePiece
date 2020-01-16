//
//  Status.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Swim

public enum RetweetedStatus : Decodable {
	
	indirect case Value(Status)
}

public struct Status : Decodable {
	
	public var coordinates: CoordinatesBox?
	public var favorited: Bool
	public var createdAt: Date
	public var truncated: Bool
	public var idStr: String
	public var entities: Entities?
	public var inReplyTo: InReplyTo?
	public var text: String
	public var contributors: String?
	public var retweetCount: Int
	public var id: UInt64
	public var geo: CoordinatesBox?
	public var retweeted: Bool
	public var retweetedStatus: RetweetedStatus?
	public var place: Place?
	public var possiblySensitive: Bool?
	public var user: User
	public var lang: String?
	public var source: String
	
	public enum CodingKeys : String, CodingKey {
		
		case coordinates
		case favorited
		case createdAt
		case truncated
		case idStr = "id_str"
		case entities
		case inReplyToUserIdStr = "in_reply_to_user_id_str"
		case inReplyToStatusIdStr = "in_reply_to_status_id_str"
		case inReplyToUserId = "in_reply_to_user_id"
		case inReplyTo_ScreenName = "in_reply_to_screen_name"
		case inReplyToStatusId = "in_reply_to_status_id"
		case text
		case contributors
		case retweetCount = "retweet_count"
		case id
		case geo
		case retweeted
		case retweetedStatus = "retweeted_status"
		case place
		case possiblySensitive = "possibly_sensitive"
		case user
		case lang
		case source
	}
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
		
		return retweetedStatus != nil
	}

	private func applyAttribute(text: NSMutableAttributedString, urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor) {
		
		text.beginEditing()
		
		defer {
			
			text.endEditing()
		}
		
		if let entities = entities {

			let baseAttributes = { () -> [NSAttributedString.Key : Any] in
				
				var results = [NSAttributedString.Key : Any]()
				
				text.enumerateAttributes(in: NSMakeRange(0, text.length), options: []) { (attributes: [NSAttributedString.Key : Any], range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
					
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
				var link: Foundation.URL
				
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
				
				func attributedTextWithBaseAttributes(baseAttributes: [NSAttributedString.Key : Any]) -> NSAttributedString {
				
					return NSAttributedString(string: displayText, attributes: attributesWithBaseAttributes(baseAttributes: baseAttributes))
				}
				
				var range: NSRange {
					
					return NSRange(indices)
				}
				
				func attributesWithBaseAttributes(baseAttributes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any] {
					
					var results = baseAttributes
					
					results[.link] = link
					results[.foregroundColor] = color
					results[.underlineStyle] = [] as NSUnderlineStyle
					results[.underlineColor] = NSColor.clear
					
					return results
				}
			}

			let linkItems = [
				
				entities.urls?.map { LinkItem.init($0, color: urlColor) },
				entities.hashtags?.map { LinkItem.init($0, color: hashtagColor) },
				entities.media?.map { LinkItem.init($0, color: urlColor) },
				entities.userMentions?.map { LinkItem.init($0, color: mentionColor) }
				]
				.compactMap { $0 }
				.flatMap { $0 }
			
			for item in linkItems.sortedByIndicesDescend {
				
				text.replaceCharacters(in: item.range, with: item.attributedTextWithBaseAttributes(baseAttributes: baseAttributes))
			}
		}
	}

	public func attributedText(urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor) -> NSAttributedString {
	
		let text = NSMutableAttributedString(string: self.text)
		
		applyAttribute(text: text, urlColor: urlColor, hashtagColor: hashtagColor, mentionColor: mentionColor)
		
		return text.copy() as! NSAttributedString
	}
	
	public func attributedText(urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor, tweak: (NSMutableAttributedString) throws -> Void) rethrows -> NSAttributedString {
		
		let text = NSMutableAttributedString(string: self.text)
		
		// first, apply attributes to entire text.
		try tweak(text)
		
		// then, apply attributes to parts of text.
		applyAttribute(text: text, urlColor: urlColor, hashtagColor: hashtagColor, mentionColor: mentionColor)
		
		return text.copy() as! NSAttributedString
	}
}

extension Sequence where Element == Status {

	public func orderByNewCreationDate() -> [Element] {
	
		return sorted { $0.createdAt > $1.createdAt }
	}
	
	public func excludeRetweets() -> [Element] {
		
		return filter { !$0.retweeted }
	}
	
	public func originalTweetAtFirst() -> Element? {
		
		return first { $0.retweeted }
	}
}

// MARK: - Decodable

extension RetweetedStatus {
	
	public init(from decoder: Decoder) throws {
		
		self = try .Value(Status(from: decoder))
	}
}

extension Status {
	
	public init(from decoder: Decoder) throws {
	
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		coordinates = try container.decode(CoordinatesBox.self, forKey: .coordinates)
		favorited = try container.decode(Bool.self, forKey: .favorited)
		createdAt = try container.decode(Date.self, forKey: .createdAt)
		truncated = try container.decode(Bool.self, forKey: .truncated)
		idStr = try container.decode(String.self, forKey: .idStr)
		entities = try container.decode(Entities.self, forKey: .entities)
		
		inReplyTo = try InReplyTo(from: decoder)
		
		text = try container.decode(String.self, forKey: .text)
		contributors = try container.decode(String.self, forKey: .contributors)
		retweetCount = try container.decode(Int.self, forKey: .retweetCount)
		id = try container.decode(UInt64.self, forKey: .id)
		geo = try container.decode(CoordinatesBox.self, forKey: .geo)
		retweeted = try container.decode(Bool.self, forKey: .retweeted)
		retweetedStatus = try container.decode(RetweetedStatus.self, forKey: .retweetedStatus)
		place = try container.decode(Place.self, forKey: .place)
		possiblySensitive = try container.decode(Bool.self, forKey: .possiblySensitive)
		user = try container.decode(User.self, forKey: .user)
		lang = try container.decode(String.self, forKey: .lang)
		source = try container.decode(String.self, forKey: .source)
	}
}
