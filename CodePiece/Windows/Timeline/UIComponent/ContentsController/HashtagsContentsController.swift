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

@MainActor
final class HashtagsContentsController : TimelineContentsController {
	
	override var kind: TimelineKind {
		
		.hashtags
	}
	
	var dataSource = GroupedTweetContentsDataSource()
	
	var hashtags: HashtagSet = [] {
		
		didSet (previousHashtags) {
			
			guard hashtags != previousHashtags else {
				
				return
			}

			if dataSource.appendHashtags(hashtags: hashtags).passed {

				Log.information("Hashtag did change: \(hashtags)")
				delegate?.timelineContentsNeedsUpdate?(self)
			}
		}
	}
	
	override var tableViewDataSource: TimelineTableDataSource {
		
		dataSource
	}
	
	override var associatedHashtags: HashtagSet {
	
		hashtags
	}
	
	override func activate() {
		
		super.activate()
		
		observe(HashtagsDidChangeNotification.self) { [unowned self] notification in
			
			hashtags = notification.hashtags
		}
		
		// Following code is disabled because the tweet you posted cannnot detect immediately.
//		observe(notification: PostCompletelyNotification.self) { [unowned self] notification in
//
//			guard notification.hashtags == self.hashtags else {
//
//				return
//			}
//
//			DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//
//				self.delegate?.timelineContentsNeedsUpdate?(self)
//			}
//		}
		
		hashtags = NSApp.settings.appState.hashtags ?? []
	}
	
	override func updateContents() async throws -> UpdateResult {
		
		let query = hashtags.searchQuery
		
		guard !query.isEmpty else {
			
			return UpdateResult.nothing
		}
		
				
		let options = API.SearchOptions(
			
			sinceId: dataSource.latestTweetIdForHashtags(hashtags: hashtags)
		)
		
		let statuses = try await NSApp.twitterController.search(tweetWith: query, options: options)

		HashtagsTimelineDidUpdateNotification(statuses: statuses).post()
		
		return UpdateResult(statuses, associatedHashtags: hashtags)
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
			.toTimelineTweetItems(hashtags: hashtags)
			.timelineItemsAppend(items: dataSource.items)
			.prefix(maxTimelineRows)
		
		dataSource.items = Array(newTweets)
	}
}
