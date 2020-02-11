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

final class RelatedTweetsContentsController : TimelineContentsController, NotificationObservable {
	
	private struct QueryControl {
		
		var lengthMargin = 30
		var step = 5
		var upperLimit = 200
		
		mutating func reduce() {
			
			guard lengthMargin < upperLimit else {
			
				return
			}
			
			lengthMargin = min(upperLimit, lengthMargin + step)
		}
	}

	private var queryControl = QueryControl()
	
	var statusesAutoUpdateIntervalForAppeared: Double {
		
		return owner!.statusesAutoUpdateInterval
	}
	
	var statusesAutoUpdateIntervalForDisappeared: Double {
		
		return owner!.statusesAutoUpdateInterval * 2.5
	}
	
	override var kind: TimelineKind {
		
		return .relatedTweets
	}
	
	var dataSource = ManagedByHashtagsContentsDataSource()
	
	private var needsUpdate = false {
		
		didSet {
			
			if needsUpdate {
				
				DispatchQueue.main.async(execute: checkNeedsUpdates)
			}
		}
	}
	
	var relatedUsers: Set<RelatedUser> = []
	var hashtags: HashtagSet = NSApp.settings.appState.hashtags ?? [] {
		
		didSet (previousHashtags) {
			
			guard hashtags != previousHashtags else {
				
				return
			}

			if dataSource.appendHashtags(hashtags: hashtags).passed {

				NSLog("Hashtag did change: \(hashtags)")
				needsUpdate = true
			}
		}
	}
	
	private func checkNeedsUpdates() {
		
		if needsUpdate {
			
			needsUpdate = false
			delegate?.timelineContentsNeedsUpdate?(self)
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
			
			self.relatedUsers = []
			self.hashtags = notification.hashtags
			self.needsUpdate = true
		}
		
		observe(HashtagsTimelineDidUpdateNotification.self) { [unowned self] notification in
			
			let users = notification.statuses.map { $0.user }
			
			self.relatedUsers.append(users: users)
			self.needsUpdate = true
		}
		
		owner!.message.send(.setAutoUpdateInterval(statusesAutoUpdateIntervalForDisappeared))
		
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
	
	override func timelineViewWillAppear(isTableViewAssigned: Bool) {
	
		super.timelineViewWillAppear(isTableViewAssigned: isTableViewAssigned)
		
		guard isTableViewAssigned, let owner = owner else {
			
			return
		}
		
		owner.message.send(.setAutoUpdateInterval(statusesAutoUpdateIntervalForAppeared))
	}
	
	override func timelineViewDidDisappear() {

		super.timelineViewDidDisappear()
		
		guard let owner = owner else {
			
			return
		}
		
		owner.message.send(.setAutoUpdateInterval(statusesAutoUpdateIntervalForDisappeared))
	}
	
	override func updateContents(callback: @escaping (UpdateResult) -> Void) {
		
		let query = relatedUsers.tweetFromAllUsersQuery(withQueryLengthMargin: queryControl.lengthMargin)
		
		guard !query.isEmpty else {
			
			callback(.success(([], associatedHashtags: [])))
			return
		}
		
		let options = API.SearchOptions(
			
			sinceId: dataSource.latestTweetIdForHashtags(hashtags: hashtags)
		)
		
		NSApp.twitterController.search(tweetWith: query, options: options) { result in
			
			switch result {
				
			case .success(let statuses):
				callback(.success((statuses, self.hashtags)))
				
			case .failure(.missingOrInvalidUrlParameter):
				self.queryControl.reduce()
				NSLog("Reducing max uplimit margin for searching related tweets query length to \(self.queryControl.lengthMargin)")
				callback(.failure(.missingOrInvalidUrlParameter))
				
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
