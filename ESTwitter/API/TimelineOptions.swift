//
//  SearchOptions.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

extension API {
	
	public struct TimelineOptions {
		
		var sinceId: String?
		var maxId: String?
		var count: Int?
		var trimUser: Bool?
		var excludeReplies: Bool?
		var contributorDetails: Bool?
		var includeRetweets: Bool?
		var includeEntities: Bool?
		var tweetMode: TweetMode
		
		public init(sinceId: String? = nil, maxId: String? = nil, count: Int? = nil, trimUser: Bool? = nil, excludeReplies: Bool? = nil, contributorDetails: Bool? = nil, includeRetweets: Bool? = nil, includeEntities: Bool? = nil, tweetMode: TweetMode = .default) {
			
			self.sinceId = sinceId
			self.maxId = maxId
			self.count = count
			self.trimUser = trimUser
			self.excludeReplies = excludeReplies
			self.contributorDetails = contributorDetails
			self.includeRetweets = includeRetweets
			self.includeEntities = includeEntities
			self.tweetMode = tweetMode
		}
	}
}
