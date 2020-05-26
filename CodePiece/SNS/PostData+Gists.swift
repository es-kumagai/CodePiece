//
//  PostData+Gists.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

extension PostDataContainer.GistsState {
	
	var isPosted: Bool {
		
		return gist != nil
	}	
}

extension PostDataContainer {
	
	private var basenameForGists: String { return "CodePiece" }
	
	var isPostedToGists: Bool {
		
		return gistsState.isPosted
	}
	
	var hasGist: Bool {
		
		return gistsState.gist != nil
	}
	
	var appendAppTagToGists: Bool {
		
		return true
	}
	
	var appendLangTagToGists: Bool {
		
		return false
	}

	var gistPageUrl: String? {
		
		return gistsState.gist?.urls.htmlUrl.description
	}
	
	var filenameForGists: String {
		
		return basenameForGists.appendStringIfNotEmpty(string: data.language.extname, separator: ".")
	}
	
	var descriptionLengthForGists: Int {
		
		return descriptionForGists().utf16.count
	}
	
	func descriptionForGists() -> String {
	
		let hashtags = effectiveHashtagsForGists
		let appendString = "" as String?
		
		return makeDescriptionWithEffectiveHashtags(hashtags: hashtags, appendString: appendString)
	}

	var effectiveHashtagsForGists: [Hashtag] {
		
		return effectiveHashtags(withAppTag: true, withLangTag: false)
	}
}
