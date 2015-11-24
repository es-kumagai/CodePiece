//
//  DescriptionGenerator.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

func DescriptionGenerator(var description:String, language:ESGists.Language?, hashtags:ESTwitter.HashtagSet, appendAppTag:Bool, maxLength:Int? = nil, appendString:String? = nil) -> String {
	
	let apptag = appendAppTag ? CodePieceApp.hashtag : ESTwitter.Hashtag()
	let langtag = language?.hashtag ?? ESTwitter.Hashtag()

	let hashtags = ESTwitter.HashtagSet(hashtags + [ apptag, langtag ])
	
	if let maxLength = maxLength {
		
		let descriptionLength = maxLength - hashtags.twitterDisplayTextLength
		
		if description.characters.count > descriptionLength {
			
			let sourceDescription = description.characters
			
			let start = sourceDescription.startIndex
			let end = start.advancedBy(descriptionLength - 2)
			
			description = String(sourceDescription.prefixThrough(end)) + " …"
		}
	}
	
	return description
		.appendStringIfNotEmpty(appendString, separator: " ")
		.appendStringIfNotEmpty(hashtags.toTwitterDisplayText(), separator: " ")
}
