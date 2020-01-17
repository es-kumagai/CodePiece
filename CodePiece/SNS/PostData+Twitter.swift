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
		
		return postedStatus != nil
	}
}

extension PostDataContainer {
	
	var isPostedToTwitter: Bool {
		
		return twitterState.isPosted
	}
	
	var appendAppTagToTwitter: Bool {
		
		return data.appendAppTagToTwitter
	}
	
	var appendLangTagToTwitter: Bool {
		
		return hasCode
	}

	var postedTwitterText: String? {
		
		return twitterState.postedStatus?.text
	}
	
	func descriptionLengthForTwitter(includesGistsLink:Bool) -> Int {

		let countsForGistsLink = includesGistsLink ? Twitter.SpecialCounting.Media.length + Twitter.SpecialCounting.HTTPSUrl.length + 2 : 0

		return descriptionForTwitter().utf16.count + countsForGistsLink
	}
	
	func descriptionForTwitter(maxLength: Int? = nil) -> String {
		
		var maxLength = maxLength
		
		if hasGist {
			
			let twitterTotalCount = maxLength ?? 140
			let reserveUrlCount = 23
			let reserveGistCount = Twitter.SpecialCounting.Media.length
			
			maxLength = twitterTotalCount - reserveUrlCount - reserveGistCount
		}

		return makeDescriptionWithEffectiveHashtags(hashtags: effectiveHashtagsForTwitter, maxLength: maxLength, appendString: gistPageUrl)
	}
	
	var effectiveHashtagsForTwitter: ESTwitter.HashtagSet {
		
		return self.effectiveHashtags(withAppTag: appendAppTagToTwitter, withLangTag: appendLangTagToTwitter)
	}
}
