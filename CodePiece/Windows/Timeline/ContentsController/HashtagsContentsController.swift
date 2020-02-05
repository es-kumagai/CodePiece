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
	
	var dataSource = DataSource()
	
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
		
		observe(notification: HashtagsDidChangeNotification.self) { [unowned self] notification in
			
			self.hashtags = notification.hashtags
		}
	}
	
	override func updateContents(callback: @escaping (UpdateResult) -> Void) {
		
		let query = hashtags.twitterQueryText
		
		guard !query.isEmpty else {
			
			return
		}
		
				
		let options = API.SearchOptions(
			
			sinceId: dataSource.latestTweetIdForHashtags(hashtags: hashtags)
		)
		
		NSApp.twitterController.search(tweetWith: query, options: options) { result in
			
			switch result {
				
			case .success(let statuses):
				callback(.success((statuses, self.hashtags)))
				
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

// MARK: - NSTableViewDataSource

extension HashtagsContentsController {
	
	final class DataSource: NSObject, TimelineTableDataSource {
		
		private var lastTweetId = Dictionary<HashtagSet, String>()

		var items = Array<TimelineTableItem>() {
			
			didSet {
		
				items.timelineLatestTweetItem.executeIfExists(setLatestTweet)
			}
		}
		
	}
}

extension HashtagsContentsController.DataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		
		return items.count
	}
	
	func latestTweetIdForHashtags(hashtags: HashtagSet) -> String? {
		
		return lastTweetId[hashtags]
	}

	func setLatestTweet(item: TimelineTweetItem) {
		
		lastTweetId[item.currentHashtags] = item.timelineItemTweetId!
	}

	@discardableResult
	func appendHashtags(hashtags: HashtagSet) -> ProcessExitStatus {
		
		let latestHashtags = items.first?.currentHashtags
		let needAppending = { () -> Bool in
			
			switch latestHashtags {
				
			case .none:
				return true
				
			case .some(let v):
				return v != hashtags
			}
		}
		
		if needAppending() {
			
			let item = TimelineHashtagTableCellItem(previousHashtags: latestHashtags, currentHashtags: hashtags)
			
			items.insert(item, at: 0)
			
			return .passed
		}
		else {

			return .aborted(in: -1)
		}
	}
}
