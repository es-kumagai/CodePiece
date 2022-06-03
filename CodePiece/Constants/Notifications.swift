//
//  Notifications.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Ocean

import ESTwitter
import ESGists


// MARK: - Settings Notification

extension Authorization {

	struct GistAuthorizationStateDidChangeNotification : NotificationProtocol, Sendable {
		
		let isValid: Bool
		let username: String?
	}
}

struct PostCompletelyNotification : NotificationProtocol, Sendable {
	
	let container: PostDataContainer
	let postedStatus: Status?
	let hashtags: HashtagSet
}

struct PostFailedNotification : NotificationProtocol, Sendable {
	
	let error: SNSController.PostError
}

struct HashtagsChangeRequestNotification : NotificationProtocol, Sendable {
	
	let hashtags: HashtagSet
}

struct LanguageSelectionChangeRequestNotification : NotificationProtocol, Sendable {
	
	let language: Language
}

struct CodeChangeRequestNotification : NotificationProtocol, Sendable {
	
	let code: String
}

struct HashtagsDidChangeNotification : NotificationProtocol, Sendable {
	
	let hashtags: HashtagSet
}

struct HashtagsTimelineDidUpdateNotification : NotificationProtocol, Sendable {
	
	let statuses: [Status]
}

struct TimelineSelectionChangedNotification : NotificationProtocol, Sendable {
	
	let timelineViewController: TimelineViewController
	let selectedCells: [TimelineTableView.CellInfo]
}

struct TimelineReplyToSelectionRequestNotification : NotificationProtocol, Sendable {
	
}

struct MentionUpdatedNotification : NotificationProtocol, Sendable {
	
	let mentions: [Status]
	let hasNewMention: Bool
}

struct CodePieceMainViewDidLoadNotification : NotificationProtocol, Sendable {
	
}
