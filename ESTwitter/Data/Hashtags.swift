//
//  Hashtags.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public typealias HashtagSet = Set<Hashtag>

extension Sequence where Element : HashtagType {

	public func sorted() -> [Element] {
		
		sorted { $0.value < $1.value }
	}
	
	public var searchQuery: API.SearchQuery {
		
		API.SearchQuery(words: map(\.value))
	}
	
	public var twitterDisplayText: String {
		
		map { $0.value }.joined(separator: " ")
	}
}

extension Collection where Element : HashtagType {

	public var twitterDisplayTextLength: Double {
		
		var separatorCount: Double {
			
			return Double(count - 1) * 0.5
		}
		
		let wordCounts = map { hashtag in
			
			hashtag.value
				.map { TwitterCharacter($0) }
				.wordCountForPost
		}
		
		return wordCounts.reduce(separatorCount, +)
	}
}

extension Set where Element : HashtagType {
	
	public init(hashtagsDisplayText: String) {
		
		let hashtags = hashtagsDisplayText
			.split(whereSeparator: \.isWhitespace)
			.compactMap(String.init)
			.compactMap(Element.init)
		
		self.init(hashtags)
	}
}
