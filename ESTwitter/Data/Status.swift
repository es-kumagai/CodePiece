//
//  Status.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Swim

//public enum RetweetedStatus : Decodable {
//
//	indirect case Value(Status)
//}

public struct Status : Decodable {
	
	public var coordinates: Coordinates?
	public var favorited: Bool
	public var createdAt: TwitterDate
	public var truncated: Bool
	public var idStr: String
	public var entities: Entities?
	public var inReplyTo: InReplyTo?
	public var text: String
	public var contributors: String?
	public var retweetCount: Int
	public var id: UInt64
	public var geo: Geometory?
	public var retweeted: Bool
//	public var retweetedStatus: RetweetedStatus?
	public var place: Place?
//	public var possiblySensitive: Bool
	public var user: User
	public var lang: String
	public var source: String
	public var isQuoteStatus: Bool
	
	public enum CodingKeys : String, CodingKey {
		
		case coordinates
		case favorited
		case createdAt = "created_at"
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
//		case retweetedStatus = "retweeted_status"
		case place
//		case possiblySensitive = "possibly_sensitive"
		case user
		case lang
		case source
		case isQuoteStatus = "is_quote_status"
	}
}

//extension RetweetedStatus {
//
//	public var status:Status {
//
//		switch self {
//
//		case .Value(let value):
//			return value
//		}
//	}
//}

extension Status {

	func normalizedEntities<Entity>(_ entities: [Entity]?, for text: String) -> [Entity]? where Entity : EntityUnit {
		
		guard let entities = entities else {
			
			return nil
		}
		
		let wordCountsByTwitterCharacter = text.twitterCharacterView.map { $0.wordCountForIndices }
		let wordCountsByUtf16Character = text.twitterCharacterView.map { $0.unitCount }

		var wordCountsDiffTable: [Int] {

			let diffsBetweenTwitterAndInternal = zip(wordCountsByTwitterCharacter, wordCountsByUtf16Character).map { $1 - $0 }

			let firstDiffs = [0]
			let followingDiffs = zip(diffsBetweenTwitterAndInternal, wordCountsByTwitterCharacter).flatMap { (diff: Int, twitterCharacterPadding: Int) -> [Int] in
				
				if twitterCharacterPadding > 1 {
					
					return [ diff ] + Array(repeating: 0, count: twitterCharacterPadding - 1)
				}
				else {
					
					return [diff]
				}
			}
			
			return firstDiffs + followingDiffs
		}
		
		return entities.map { entity in

			guard wordCountsDiffTable.endIndex > entity.indices.startIndex else {
				
				NSLog("""
					WARNING: Ignore entity normalizing.
					\tEntity Text: \(entity.displayText)
					\tEntity Indices: \(entity.indices)
					\tWord count Table (\(wordCountsDiffTable.count)): \(wordCountsDiffTable)
					""")
				
				return entity
			}
			
			let effectiveCountsDiffTable = wordCountsDiffTable[0 ..< entity.indices.startIndex]
			let offset = effectiveCountsDiffTable.reduce(0, +)
			
			var newEntity = entity
			
			newEntity.indices = entity.indices.added(offset: offset)
			
//			NSLog("""
//				NOTE: Entity normalizing.
//				\tEntity Text: \(entity.displayText)
//				\tEntity Indices: \(entity.indices)
//				\tNew Entity Indices: \(newEntity.indices)
//				\tOffset: \(offset)
//				\tDiff Table (\(wordCountsDiffTable.count)): \(wordCountsDiffTable)
//				\tEffective Diff Table (\(effectiveCountsDiffTable.count)): \(effectiveCountsDiffTable)
//				""")

			return newEntity
		}
	}
	
	func normalizedEntities(for text: String) -> Entities? {

		guard let entities = entities else {

			return nil
		}
		
		let urls = normalizedEntities(entities.urls, for: text)
		let hashtags = normalizedEntities(entities.hashtags, for: text)
		let userMentions = normalizedEntities(entities.userMentions, for: text)
		let media = normalizedEntities(entities.media, for: text)

		return Entities(urls: urls, hashtags: hashtags, userMentions: userMentions, media: media)
	}
}

extension Status {
	
	private func applyingAttribute(to text: String, urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor) -> NSAttributedString {
		
		var result = NSMutableAttributedString(string: text)
		
		if let entities = normalizedEntities(for: text) {

			let baseAttributes = { () -> [NSAttributedString.Key : Any] in

				var results = [NSAttributedString.Key : Any]()

				result.enumerateAttributes(in: NSMakeRange(0, result.length), options: []) { (attributes: [NSAttributedString.Key : Any], range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

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
				var link: URL

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

					// FIXME: link の色に邪魔されて foregroundColor が実質無効になる様子です。
					results[.link] = link
					results[.foregroundColor] = color
					results[.underlineStyle] = 0
					results[.underlineColor] = NSColor.clear

					return results
				}
			}

			let linkItems = [

				entities.urls?.map { LinkItem($0, color: urlColor) },
				entities.hashtags?.map { LinkItem($0, color: hashtagColor) },
				entities.media?.map { LinkItem($0, color: urlColor) },
				entities.userMentions?.map { LinkItem($0, color: mentionColor) }
				]
				.compactMap { $0 }
				.flatMap { $0 }
			
			for item in linkItems.sortedByIndicesDescend {

				var canApplyingItem: Bool {
					
					guard item.range.location >= 0 else {
						
						return false
					}
					
					let internalCount = result.string.utf16.count
					
					return internalCount >= item.range.location + item.range.length
				}

				let subtext = item.attributedTextWithBaseAttributes(baseAttributes: baseAttributes)

				guard canApplyingItem else {

					NSLog("""
						WARNING: Ignore applying an entity because it's range is out of bounds.
						\tEntity text: \(item.displayText)
						\tIndices: \(item.indices.startIndex) ..< \(item.indices.endIndex)
						\tRange: \(item.range)
						\tType: \(type(of: item))
						\tTarget Text: \(result.string.prefix(50).replacingOccurrences(of: "\n", with: " "))...
						\tTarget Text Length: \(result.length)
						""")
					continue
				}
				
//				NSLog("""
//					NOTE: Applying an entity because it's range is out of bounds.
//					\tEntity text: \(item.displayText)
//					\tIndices: \(item.indices.startIndex) ..< \(item.indices.endIndex)
//					\tRange: \(item.range)
//					\tType: \(type(of: item))
//					\tTarget Text: \(result.string.prefix(50).replacingOccurrences(of: "\n", with: " "))...
//					\tTarget Text Length: \(result.length)
//					""")

				result.replaceCharacters(in: item.range, with: subtext)
			}
						
//			text.replaceCharacters(in: NSRange(location: 5, length: 4), with: NSAttributedString(string: "XX", attributes: [NSAttributedString.Key.foregroundColor : NSColor.red]))
		}
		
		return result.copy() as! NSAttributedString
	}

	public func attributedText(urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor) -> NSAttributedString {
	
		return applyingAttribute(to: text, urlColor: urlColor, hashtagColor: hashtagColor, mentionColor: mentionColor)
	}
	
	public func attributedText(urlColor: NSColor, hashtagColor: NSColor, mentionColor: NSColor, customizeExpression: (NSMutableAttributedString) throws -> Void) rethrows -> NSAttributedString {
		
		let text = applyingAttribute(to: self.text, urlColor: urlColor, hashtagColor: hashtagColor, mentionColor: mentionColor).mutableCopy() as! NSMutableAttributedString

		text.beginEditing()
		
		defer {
			
			text.endEditing()
		}
		
		try customizeExpression(text)

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

//extension RetweetedStatus {
//
//	public init(from decoder: Decoder) throws {
//
//		self = try .Value(Status(from: decoder))
//	}
//}

extension Status {
	
	public init(from decoder: Decoder) throws {
	
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		coordinates = try container.decode(Coordinates?.self, forKey: .coordinates)
		favorited = try container.decode(Bool.self, forKey: .favorited)
		createdAt = try container.decode(TwitterDate.self, forKey: .createdAt)
		truncated = try container.decode(Bool.self, forKey: .truncated)
		idStr = try container.decode(String.self, forKey: .idStr)
		entities = try container.decode(Entities?.self, forKey: .entities)
		
		inReplyTo = try InReplyTo(from: decoder)
		
		text = try container.decode(String.self, forKey: .text)
		contributors = try container.decode(String?.self, forKey: .contributors)
		retweetCount = try container.decode(Int.self, forKey: .retweetCount)
		id = try container.decode(UInt64.self, forKey: .id)
		geo = try container.decode(Geometory?.self, forKey: .geo)
		retweeted = try container.decode(Bool.self, forKey: .retweeted)
//		retweetedStatus = try container.decode(RetweetedStatus?.self, forKey: .retweetedStatus)
		place = try container.decode(Place?.self, forKey: .place)
//		possiblySensitive = try container.decode(Bool.self, forKey: .possiblySensitive)
		user = try container.decode(User.self, forKey: .user)
		lang = try container.decode(String.self, forKey: .lang)
		source = try container.decode(String.self, forKey: .source)
		isQuoteStatus = try container.decode(Bool.self, forKey: .isQuoteStatus)
	}
}
