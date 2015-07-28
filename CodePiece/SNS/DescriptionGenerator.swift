//
//  DescriptionGenerator.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGist

func DescriptionGenerator(var description:String, language:ESGist.Language?, hashtag:Twitter.Hashtag, appendAppTag:Bool, maxLength:Int? = nil, appendString:String? = nil) -> String {
	
	let apptag = Twitter.Hashtag(appendAppTag ? "#CodePiece" : "")
	let langtag = Twitter.Hashtag(language.map { $0.description } ?? "")

	if let maxLength = maxLength {
		
		let apptagLength = apptag.length
		let hashtagLength = hashtag.length
		let langtagLength = langtag.length
		
		let descriptionLength = maxLength - apptagLength - hashtagLength - langtagLength
		
		if description.characters.count > descriptionLength {
			
			let sourceDescription = description.characters
			
			let start = sourceDescription.startIndex
			let end = advance(start, descriptionLength - 2)
			
			description = String(sourceDescription[start ..< end]) + " …"
		}
	}
	
	return description
		.appendStringIfNotEmpty(appendString, separator: " ")
		.appendStringIfNotEmpty(langtag.value, separator: " ")
		.appendStringIfNotEmpty(hashtag.value, separator: " ")
		.appendStringIfNotEmpty(apptag.value, separator: " ")
}
