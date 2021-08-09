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

final class SearchTweetsContentsController : TimelineContentsController, NotificationObservable {
	
	override var kind: TimelineKind {
		
		return .searchTweets
	}
	
	var dataSource = ManagedByTweetContentsDataSource()
	
	var searchQuery: String = "" {

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
	
	override func updateContents(callback: @escaping (UpdateResult) -> Void) {
		
		let query = searchQuery
		
		guard !query.isEmpty else {
			
			callback(.success(([], associatedHashtags: [])))
			return
		}
				
		let options = API.SearchOptions(
			
			sinceId: dataSource.lastTweetId
		)
		
		NSApp.twitterController.search(tweetWith: query, options: options) { result in
			
			switch result {
				
			case .success(let statuses):
				callback(.success((statuses, [])))
				
			case .failure(let error):
				callback(.failure(error))
			}
		}
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
