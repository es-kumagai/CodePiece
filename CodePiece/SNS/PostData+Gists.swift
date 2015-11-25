//
//  PostData+Gists.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

extension PostData {
	
	var appendAppTagToGists: Bool {
		
		return true
	}
	
	var appendLangTagToGists: Bool {
		
		return false
	}
}

extension PostDataContainer.GistsState {
	
	var isPosted: Bool {
		
		return self.gist.isExists
	}	
}

extension PostDataContainer {
	
	private var basenameForGists: String { return "CodePiece" }
	
	var isPostedToGists: Bool {
		
		return self.gistsState.isPosted
	}
	
	var hasGist: Bool {
		
		return self.gistsState.gist.isExists
	}
	
	var gistPageUrl: String? {
		
		return gistsState.gist?.urls.htmlUrl.description
	}
	
	var filenameForGists: String {
		
		return self.basenameForGists.appendStringIfNotEmpty(self.data.language.extname, separator: ".")
	}
	
	var descriptionLengthForGists: Int {
		
		return self.descriptionForGists().utf16.count
	}
	
	func descriptionForGists() -> String {
	
		let hashtags = self.effectiveHashtagsForGists
		let appendAppTag = self.data.appendAppTagToGists
		let appendLangTag = self.data.appendLangTagToGists
		let appendString = String?()
		
		return self.makeDescriptionWithEffectiveHashtags(hashtags, withAppTag: appendAppTag, withLangTag: appendLangTag, appendString: appendString)
	}

	var effectiveHashtagsForGists: ESTwitter.HashtagSet {
		
		return self.effectiveHashtags(withAppTag: true, withLangTag: false)
	}
}
