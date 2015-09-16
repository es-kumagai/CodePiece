//
//  DescriptionGenerator.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists

func DescriptionGenerator(var description:String, language:ESGists.Language?, hashtag:Twitter.Hashtag, appendAppTag:Bool, maxLength:Int? = nil, appendString:String? = nil) -> String {
	
	let apptag = appendAppTag ? CodePieceApp.hashtag : Twitter.Hashtag()
	let langtag = language?.hashtag ?? Twitter.Hashtag()

	if let maxLength = maxLength {
		
		let apptagLength = apptag.length
		let hashtagLength = hashtag.length
		let langtagLength = langtag.length
		
		let descriptionLength = maxLength - apptagLength - hashtagLength - langtagLength
		
		if description.characters.count > descriptionLength {
			
			let sourceDescription = description.characters
			
			let start = sourceDescription.startIndex
			let end = start.advancedBy(descriptionLength - 2)
			
			description = String(sourceDescription[start ..< end]) + " …"
		}
	}
	
	return description
		.appendStringIfNotEmpty(appendString, separator: " ")
		.appendStringIfNotEmpty(langtag.value, separator: " ")
		.appendStringIfNotEmpty(hashtag.value, separator: " ")
		.appendStringIfNotEmpty(apptag.value, separator: " ")
}
