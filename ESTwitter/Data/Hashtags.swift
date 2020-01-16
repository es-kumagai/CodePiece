//
//  Hashtags.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public typealias HashtagSet = Set<Hashtag>

extension Set where Element : HashtagType {
	
	public init(hashtagsDisplayText: String) {
		
		let hashtags = hashtagsDisplayText.split(separator: " ").compactMap(String.init).compactMap(Element.init)
		
		self.init(hashtags)
	}
	
	public func toTwitterQueryText() -> String {
		
		return self.toTwitterDisplayText()
	}
	
	public func toTwitterDisplayText() -> String {
		
		return map { $0.value } .joined(separator: " ")
	}
	
	public var twitterDisplayTextLength: Int {
		
		func numberOfSpaces() -> Int {
			
			return count - 1
		}
		
		switch count {
			
		case 0:
			return 0
			
		case 1:
			return first!.length
			
		default:
			return reduce(numberOfSpaces()) { $0 + $1.length }
		}
	}
}
