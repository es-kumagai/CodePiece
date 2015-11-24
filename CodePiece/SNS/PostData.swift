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
}

extension PostDataContainer {
	
	func postedToTwitter() {
		
		self.isPostedToTwitter = true
	}
	
	func postedToGist(gist: ESGists.Gist) {
		
		self.gist = gist
	}
}
