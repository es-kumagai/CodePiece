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

final class MentionsContentsController : TimelineContentsController, NotificationObservable {
	
	override var kind: TimelineKind {
		
		return .mentions
	}
	
	var dataSource = DataSource()
		
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
	
	override func updateContents(callback: @escaping (UpdateResult) -> Void) {

		let options = API.MentionOptions(
			
			sinceId: dataSource.lastTweetId
		)
		
		NSApp.twitterController.mentions(options: options) { result in
			
			func success(_ statuses: [Status]) {
			
				if statuses.count > 0 {

					MentionUpdatedNotification(mentions: statuses, includesNewMention: self.alreadyHasMentions).post()
				}

				callback(.success((statuses, [])))
			}
			
			switch result {
				
			case .success(let statuses):
				success(statuses)
				
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

extension MentionsContentsController {
	
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

extension MentionsContentsController.DataSource {

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
