//
//  Hashtags.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public typealias HashtagSet = Set<Hashtag>

extension Set where Element : HashtagType {
	
	private var validElements: [Element] {
	
		return self.filter { !$0.isEmpty }
	}
	
	public init(hashtagsDisplayText: String) {
		
		let hashtags = hashtagsDisplayText.split(" ").map { Element(hashtagValue:$0) }
		
		self.init(hashtags)
	}
	
	public func toTwitterQueryText() -> String {
		
		return self.toTwitterDisplayText()
	}
	
	public func toTwitterDisplayText() -> String {
		
		return self.validElements.map { $0.value } .joinWithSeparator(" ")
	}
	
	public var twitterDisplayTextLength: Int {
		
		let elements = self.validElements
		let numberOfSpaces = { elements.count.predecessor() }
		
		switch elements.count {
			
		case 0:
			return 0
			
		case 1:
			return elements.first!.length
			
		default:
			return elements.reduce(numberOfSpaces()) { $0 + $1.length }
		}
	}
}
