//
//  PostOptions.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension API {

	public struct PostOption {
		
		var inReplyTo: StatusId?
		var mediaIDs: [MediaId]
		var attachmentUrl: Foundation.URL?
		var coordinate: Coordinate.Item?
		var autoPopulateReplyMetadata: Bool?
		var excludeReplyUserIds: Bool?
		var placeId: Double?
		var displayCoordinates: Bool?
		var trimUser: Bool?
		var tweetMode: TweetMode
		
		public init(inReplyTo: StatusId? = nil, mediaIDs: [MediaId] = [], attachmentUrl: Foundation.URL? = nil, coordinate: Coordinate.Item? = nil, autoPopulateReplyMetadata: Bool? = nil, excludeReplyUserIds: Bool? = nil, placeId: Double? = nil, displayCoordinates: Bool? = nil, trimUser: Bool? = nil, tweetMode: TweetMode = .default) {
			
			self.inReplyTo = inReplyTo
			self.mediaIDs = mediaIDs
			self.attachmentUrl = attachmentUrl
			self.coordinate = coordinate
			self.autoPopulateReplyMetadata = autoPopulateReplyMetadata
			self.excludeReplyUserIds = excludeReplyUserIds
			self.placeId = placeId
			self.displayCoordinates = displayCoordinates
			self.trimUser = trimUser
			self.tweetMode = tweetMode
		}
	}
}
