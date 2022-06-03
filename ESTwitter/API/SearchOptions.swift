//
//  SearchOptions.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

extension API {
	
	public struct SearchOptions : Sendable {
		
		var geocode: String?
		var language: String?
		var locale: String?
		var resultType: String?
		var count: Int?
		var until: String?
		var sinceId: String?
		var maxId: String?
		var includeEntities: Bool?
		var callback: String?
		var tweetMode: TweetMode
		
		public init(geocode: String? = nil, language: String? = nil, locale: String? = nil, resultType: String? = nil, count: Int? = nil, until: String? = nil, sinceId: String? = nil, maxId: String? = nil, includeEntities: Bool? = nil, callback: String? = nil, tweetMode: TweetMode = .default) {
			
			self.geocode = geocode
			self.language = language
			self.locale = locale
			self.resultType = resultType
			self.count = count
			self.until = until
			self.sinceId = sinceId
			self.maxId = maxId
			self.includeEntities = includeEntities
			self.callback = callback
			self.tweetMode = tweetMode
		}
	}
}
