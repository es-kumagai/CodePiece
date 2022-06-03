//
//  PostOptions.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/28.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import ESTwitter

extension API.PostOption {
	
	init(from container: isolated PostDataContainer) {
		
		self = API.PostOption(
			inReplyTo: container.data.replyTo?.idStr,
			mediaIDs: container.twitterState.mediaIDs,
			attachmentUrl: nil,
			coordinate: nil,
			autoPopulateReplyMetadata: nil,
			excludeReplyUserIds: nil,
			placeId: nil,
			displayCoordinates: nil,
			trimUser: nil,
			tweetMode: .default
		)
	}
}

