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
}

extension PostDataContainer.TwitterState {
	
	var isPosted: Bool {
		
		return self.postedObjects.isExists
	}
}

extension PostDataContainer {
	
	var isPostedToTwitter: Bool {
		
		return self.twitterState.isPosted
	}
	
	var appendAppTagToTwitter: Bool {
		
		return self.data.appendAppTagToTwitter
	}
	
	var appendLangTagToTwitter: Bool {
		
		if self.hasGist {
			
			return true
		}
		else {
			
			return false
		}
	}

	var postedTwitterText: String? {
		
		return self.twitterState.postedObjects?["text"] as? String
	}
	
	func descriptionLengthForTwitter(includesGistsLink includesGistsLink:Bool) -> Int {

		let countsForGistsLink = includesGistsLink ? Twitter.SpecialCounting.Media.length + Twitter.SpecialCounting.HTTPSUrl.length + 2 : 0

		return self.descriptionForTwitter().utf16.count + countsForGistsLink
	}
	
	func descriptionForTwitter(var maxLength: Int? = nil) -> String {
		
		if self.hasGist {
			
			let twitterTotalCount = maxLength ?? 140
			let reserveUrlCount = 23
			let reserveGistCount = self.hasGist ? Twitter.SpecialCounting.Media.length : 0
			
			maxLength = twitterTotalCount - reserveUrlCount - reserveGistCount
		}

		let hashtags = self.effectiveHashtagsForTwitter
		let appendAppTag = self.appendAppTagToTwitter
		let appendLangTag = self.appendLangTagToTwitter
		let appendString = self.gistPageUrl
		
		return self.makeDescriptionWithEffectiveHashtags(hashtags, withAppTag: appendAppTag, withLangTag: appendLangTag, maxLength: maxLength, appendString: appendString)
	}
	
	var effectiveHashtagsForTwitter: ESTwitter.HashtagSet {
		
		let appendAppTag = self.appendAppTagToTwitter
		let appendLangTag = self.appendLangTagToTwitter
		
		return self.effectiveHashtags(withAppTag: appendAppTag, withLangTag: appendLangTag)
	}
}
