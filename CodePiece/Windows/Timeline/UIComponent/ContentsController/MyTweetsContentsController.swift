//
//  MyTweetsContentsController.swift
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
final class MyTweetsContentsController : TimelineContentsController {
	
	override var kind: TimelineKind {
		
		.myTweets
	}
	
	var dataSource = SimpleTweetContentsDataSource()
		
	override var tableViewDataSource: TimelineTableDataSource {
		
		dataSource
	}
	
	override func activate() {
		
		super.activate()
	
		observe(PostCompletelyNotification.self) { [unowned self] notification in
			
			delegate?.timelineContentsNeedsUpdate?(self)
		}
	}

	override func timelineViewDidAppear() {

		super.timelineViewDidAppear()
		
		delegate?.timelineContentsNeedsUpdate?(self)
	}
	
	override func updateContents() async throws -> Update {

		let options = API.TimelineOptions(sinceId: dataSource.lastTweetId)

		let statuses = try await NSApp.twitterController.timeline(options: options)
		
		return Update(statuses)
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
