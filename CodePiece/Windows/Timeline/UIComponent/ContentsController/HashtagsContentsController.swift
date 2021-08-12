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

final class HashtagsContentsController : TimelineContentsController, NotificationObservable {
	
	override var kind: TimelineKind {
		
		return .hashtags
	}
	
	var dataSource = GroupedTweetsContentsDataSource()
	
	var hashtags: HashtagSet = NSApp.settings.appState.hashtags ?? [] {
		
		didSet (previousHashtags) {
			
			guard hashtags != previousHashtags else {
				
				return
			}

			if dataSource.appendHashtags(hashtags: hashtags).passed {

				NSLog("Hashtag did change: \(hashtags)")
				delegate?.timelineContentsNeedsUpdate?(self)
			}
		}
	}
	
	override var tableViewDataSource: TimelineTableDataSource {
		
		return dataSource
	}
	
	override var associatedHashtags: HashtagSet {
	
		return hashtags
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
	}
	
	override func updateContents(callback: @escaping (UpdateResult) -> Void) {
		
		let query = hashtags.twitterQueryText
		
		guard !query.isEmpty else {
			
			callback(.success(([], associatedHashtags: [])))
			return
		}
		
				
		let options = API.SearchOptions(
			
			sinceId: dataSource.latestTweetIdForHashtags(hashtags: hashtags)
		)
		
		NSApp.twitterController.search(tweetWith: query, options: options) { [unowned self] result in
			
			switch result {
				
			case .success(let statuses):
				HashtagsTimelineDidUpdateNotification(statuses: statuses).post()
				callback(.success((statuses, hashtags)))
				
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
			.toTimelineTweetItems(hashtags: hashtags)
			.timelineItemsAppend(items: dataSource.items)
			.prefix(maxTimelineRows)
		
		dataSource.items = Array(newTweets)
	}
}
