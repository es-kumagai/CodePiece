//
//  PostDataExtensionForTwitter.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

extension PostDataContainer {
	
	func descriptionForTwitter(var maxLength: Int? = nil) -> String {
		
		if gist != nil {
			
			let twitterTotalCount = maxLength ?? 140
			let reserveUrlCount = 23
			let reserveGistCount = gist.map { _ in Twitter.SpecialCounting.Media.length } ?? 0
			
			maxLength = twitterTotalCount - reserveUrlCount - reserveGistCount
		}
		
		let appendAppTag = false
		let language:Language? = gist?.files.first?.1.language
		
		return DescriptionGenerator(self.data.description, language: language, hashtags: self.data.hashtags, appendAppTag: appendAppTag, maxLength: maxLength, appendString: gist?.urls.htmlUrl.description)
	}
}
