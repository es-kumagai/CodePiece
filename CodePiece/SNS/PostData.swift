//
//  PostData.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

final class PostDataContainer {

	var data: PostData
	
	private(set) var gist: ESGists.Gist? = nil
	private(set) var isPostedToTwitter: Bool = false
	
	init(_ data: PostData) {
		
		self.data = data
	}
}

struct PostData {
	
	var code: String
	var description: String
	var language: ESGists.Language
	var hashtags: ESTwitter.HashtagSet
	
	var appendAppTagToTwitter:Bool = false
}

extension PostDataContainer {
	
	func postedToTwitter() {
		
		self.isPostedToTwitter = true
	}
	
	func postedToGist(gist: ESGists.Gist) {
		
		self.gist = gist
	}
	
	func effectiveHashtags(withAppTag withAppTag:Bool, withLangTag:Bool) -> ESTwitter.HashtagSet {
		
		let apptag = withAppTag ? CodePieceApp.hashtag : ESTwitter.Hashtag()
		let langtag = withLangTag ? self.data.language.hashtag : ESTwitter.Hashtag()
		
		return ESTwitter.HashtagSet(self.data.hashtags + [ apptag, langtag ])
	}
	
	func makeDescriptionWithEffectiveHashtags(hashtags:ESTwitter.HashtagSet, withAppTag:Bool, withLangTag:Bool, maxLength:Int? = nil, appendString:String? = nil) -> String {
		
		let getTruncatedDescription = { (description: String, maxLength: Int) -> String in
			
			let descriptionLength = maxLength - hashtags.twitterDisplayTextLength
			
			guard description.characters.count > descriptionLength else {
				
				return description
			}
			
			let sourceDescription = description.characters
			
			let start = sourceDescription.startIndex
			let end = start.advancedBy(descriptionLength - 2)
			
			return String(sourceDescription.prefixThrough(end)) + " …"
		}
		
		let getDescription = { () -> String in

			let description = self.data.description
			
			if let maxLength = maxLength {
				
				return getTruncatedDescription(description, maxLength)
			}
			else {
				
				return description
			}
		}
		
		return getDescription()
			.appendStringIfNotEmpty(appendString, separator: " ")
			.appendStringIfNotEmpty(hashtags.toTwitterDisplayText(), separator: " ")
	}
}