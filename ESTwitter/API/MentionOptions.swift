//
//  MentionOptions.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

extension API {
	
	public struct MentionOptions {
		
		var sinceId: String?
		var maxId: String?
		var count: Int?
		var trimUser: Bool?
		var contributorDetails: Bool?
		var includeEntities: Bool?
		var tweetMode: TweetMode
		
		public init(sinceId: String? = nil, maxId: String? = nil, count: Int? = nil, trimUser: Bool? = nil, contributorDetails: Bool? = nil, includeEntities: Bool? = nil, tweetMode: TweetMode = .default) {
			
			self.sinceId = sinceId
			self.maxId = maxId
			self.count = count
			self.trimUser = trimUser
			self.includeEntities = includeEntities
			self.tweetMode = tweetMode
		}
	}
}
