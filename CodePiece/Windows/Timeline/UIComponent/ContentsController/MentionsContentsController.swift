//
//  MentionsContentsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter
import Swim
import Ocean

@MainActor
final class MentionsContentsController : TimelineContentsController {
	
	override var kind: TimelineKind {
		
		return .mentions
	}
	
	var dataSource = SimpleTweetContentsDataSource()
		
	var alreadyHasMentions: Bool {
		
		return dataSource.lastTweetId != nil
	}
	
	override var tableViewDataSource: TimelineTableDataSource {
		
		return dataSource
	}
	
	override func activate() {
		
		super.activate()
	
	}

	override func timelineViewDidAppear() {

		super.timelineViewDidAppear()
		
		delegate?.timelineContentsNeedsUpdate?(self)
	}
	
	override func updateContents() async throws -> UpdateResult {

		let options = API.MentionOptions(
			
			sinceId: dataSource.lastTweetId
		)
		
		let statuses = try await NSApp.twitterController.mentions(options: options)
			
		if statuses.count > 0 {
			
			MentionUpdatedNotification(mentions: statuses, hasNewMention: alreadyHasMentions).post()
		}

		return UpdateResult(statuses)
	}
	
	override func estimateCellHeight(of row: Int) -> CGFloat {

		guard let tableView = tableView else {
			
			return 0
		}
		
		let item = dataSource.items[row]
		
		return item.timelineCellType.estimateCellHeightForItem(item: item, tableView: tableView)
	}
		
	override func appendTweets(tweets: [Status]) {
		
		let newTweets = tweets
			.orderByNewCreationDate()
			.toTimelineTweetItems(hashtags: [])
			.timelineItemsAppend(items: dataSource.items)
			.prefix(maxTimelineRows)
		
		dataSource.items = Array(newTweets)
	}
}
