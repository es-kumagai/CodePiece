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

		let countsForGistsLink = includesGistsLink ? Twitter.SpecialCounting.media.length + Twitter.SpecialCounting.httpsUrl.length + 2 : 0

		return Int(descriptionForTwitter().twitterCharacterView.wordCountForPost + countsForGistsLink)
	}
	
	func descriptionForTwitter(maxLength: Int = 140) -> String {
		
		let length: Int
		
		if hasGist {
			
			let twitterTotalCount = Double(maxLength)
			let reserveUrlCount = 23.0
			let reserveGistCount = Twitter.SpecialCounting.media.length
			
			length = Int(twitterTotalCount - reserveUrlCount - reserveGistCount)
		}
		else {
			
			length = maxLength
		}

		return makeDescriptionWithEffectiveHashtags(hashtags: effectiveHashtagsForTwitter, maxLength: length, appendString: gistPageUrl)
	}
	
	var effectiveHashtagsForTwitter: [Hashtag] {
		
		return effectiveHashtags(withAppTag: appendAppTagToTwitter, withLangTag: appendLangTagToTwitter)
	}
}
