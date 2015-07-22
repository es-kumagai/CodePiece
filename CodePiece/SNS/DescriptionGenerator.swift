//
//  DescriptionGenerator.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGist

func DescriptionGenerator(var description:String, language:ESGist.Language?, hashtag:String, appendAppTag:Bool, maxLength:Int? = nil, appendString:String? = nil) -> String {
	
	let apptag = appendAppTag ? "#CodePiece" : ""
	let hashtag = Hashtag(hashtag)
	let langtag = language.map { Hashtag($0.description) } ?? ""

	if let maxLength = maxLength {
		
		let apptagLength = apptag.characters.count
		let hashtagLength = hashtag.characters.count
		let langtagLength = langtag.characters.count
		
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
		.appendStringIfNotEmpty(langtag, separator: " ")
		.appendStringIfNotEmpty(hashtag, separator: " ")
		.appendStringIfNotEmpty(apptag, separator: " ")
}

func Hashtag(string:String) -> String {
	
	guard !string.isEmpty else {
		
		return ""
	}
	
	return string.hasPrefix("#") ? string : "#\(string)"
}