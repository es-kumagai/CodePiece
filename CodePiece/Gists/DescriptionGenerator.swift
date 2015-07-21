//
//  DescriptionGenerator.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGist

func DescriptionGenerator(description:String, language:ESGist.Language?, hashtag:String) -> String {
	
	let apptag = "#CodePiece"
	let hashtag = Hashtag(hashtag)
	let langtag = language.map { Hashtag($0.description) } ?? ""
	
	return description
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