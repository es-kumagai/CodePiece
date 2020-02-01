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
		
		public var inReplyTo: StatusId?
		public var mediaIDs: [MediaId]
		public var attachmentUrl: URL?
		public var coordinate: CoordinatesElement?
		public var autoPopulateReplyMetadata: Bool?
		public var excludeReplyUserIds: Bool?
		public var placeId: Double?
		public var displayCoordinates: Bool?
		public var trimUser: Bool?
		public var tweetMode: TweetMode
		
		public init(inReplyTo: StatusId? = nil, mediaIDs: [MediaId] = [], attachmentUrl: URL? = nil, coordinate: CoordinatesElement? = nil, autoPopulateReplyMetadata: Bool? = nil, excludeReplyUserIds: Bool? = nil, placeId: Double? = nil, displayCoordinates: Bool? = nil, trimUser: Bool? = nil, tweetMode: TweetMode = .default) {
			
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
