//
//  PostDataExtensionForTwitter.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

extension PostData {
	
	var appendLangTagToTwitter: Bool {
		
		return true
	}
}

extension PostDataContainer {
	
	func descriptionForTwitter(var maxLength: Int? = nil) -> String {
		
		if gist != nil {
			
			let twitterTotalCount = maxLength ?? 140
			let reserveUrlCount = 23
			let reserveGistCount = gist.map { _ in Twitter.SpecialCounting.Media.length } ?? 0
			
			maxLength = twitterTotalCount - reserveUrlCount - reserveGistCount
		}

		let hashtags = self.effectiveHashtagsForTwitter
		let appendAppTag = self.data.appendAppTagToTwitter
		let appendLangTag = self.data.appendLangTagToTwitter
		let appendString = gist?.urls.htmlUrl.description
		
		return self.makeDescriptionWithEffectiveHashtags(hashtags, withAppTag: appendAppTag, withLangTag: appendLangTag, maxLength: maxLength, appendString: appendString)
	}
	
	var effectiveHashtagsForTwitter: ESTwitter.HashtagSet {
		
		let appendAppTag = self.data.appendAppTagToTwitter
		let appendLangTag = self.data.appendLangTagToTwitter
		
		return self.effectiveHashtags(withAppTag: appendAppTag, withLangTag: appendLangTag)
	}
}
