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
	
	var dataSource = ManagedByTweetContentsDataSource()
		
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
