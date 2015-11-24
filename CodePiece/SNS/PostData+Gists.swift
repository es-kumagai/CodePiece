//
//  PostData+Gists.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

extension PostDataContainer {
	
	private var basenameForGists: String { return "CodePiece" }
	
	var postedToGists: Bool {
		
		return self.gist.isExists
	}
	
	var filenameForGists: String {
		
		return self.basenameForGists.appendStringIfNotEmpty(self.data.language.extname, separator: ".")
	}
	
	func descriptionForGists() -> String {
	
		return DescriptionGenerator(data.description, language: nil, hashtags: data.hashtags, appendAppTag: true)
	}
}
