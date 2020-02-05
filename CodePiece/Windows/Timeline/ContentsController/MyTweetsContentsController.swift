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

final class MyTweetsContentsController : TimelineContentsController, NotificationObservable {
	
	override var kind: TimelineKind {
		
		return .myTweets
	}
	
	var dataSource = DataSource()
		
	override var tableViewDataSource: TimelineTableDataSource {
		
		return dataSource
	}
	
	override func activate() {
		
		super.activate()
	
		observe(notification: PostCompletelyNotification.self) { [unowned self] notification in
			
			self.delegate?.timelineContentsNeedsUpdate?(self)
		}
	}

	override func timelineViewDidAppear() {

		super.timelineViewDidAppear()
		
		delegate?.timelineContentsNeedsUpdate?(self)
	}
	
	override func updateContents(callback: @escaping (UpdateResult) -> Void) {

		let options = API.TimelineOptions(
			
			sinceId: dataSource.lastTweetId
		)
		
		NSApp.twitterController.timeline(options: options) { result in
			
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

extension MyTweetsContentsController {
	
	final class DataSource: NSObject, TimelineTableDataSource {
		
		var lastTweetId: String? = nil

		var items = Array<TimelineTableItem>() {
			
			didSet (previousItems) {
		
				if let item = items.timelineLatestTweetItem {
					
					lastTweetId = item.timelineItemTweetId
				}
			}
		}
		
	}
}

extension MyTweetsContentsController.DataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		
		return items.count
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
