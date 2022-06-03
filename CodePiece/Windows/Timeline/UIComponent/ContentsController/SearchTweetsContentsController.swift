//
//  HashtagsContentsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter
import Swim
import Ocean

final class SearchTweetsContentsController : TimelineContentsController {
	
	override var kind: TimelineKind {
		
		return .searchTweets
	}
	
	var dataSource = SimpleTweetContentsDataSource()
	
	var searchQuery = API.SearchQuery() {

		didSet (previousSearchQuery) {
			
			guard searchQuery != previousSearchQuery else {
				
				return
			}

			NSLog("Search query did change: \(searchQuery)")
			dataSource.items.removeAll()
			delegate?.timelineContentsNeedsUpdate?(self)
		}
	}
	
	override var tableViewDataSource: TimelineTableDataSource {
		
		return dataSource
	}
	
	override func activate() {
		
		super.activate()
		
	}
	
	override func updateContents() async throws -> Update {
		
		let query = searchQuery
		
		guard !query.isEmpty else {
			
			return Update.nothing
		}
				
		let options = API.SearchOptions(
			
			sinceId: dataSource.lastTweetId
		)
		
		let statuses = try await NSApp.twitterController.search(tweetWith: query, options: options)
		
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
