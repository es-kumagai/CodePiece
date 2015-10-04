//
//  TimelineViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

class TimelineViewController: NSViewController {

	struct TimelineInformation {
	
		var hashtag:ESTwitter.Hashtag
		var lastTweetID:String?

		init() {
		
			self.init(hashtag: "", lastTweetID: nil)
		}
		
		init(hashtag: ESTwitter.Hashtag, lastTweetID:String?) {
			
			self.hashtag = hashtag
			self.lastTweetID = lastTweetID
		}
		
		func replaceHashtag(hashtag: ESTwitter.Hashtag) -> TimelineInformation {
			
			return TimelineInformation(hashtag: hashtag, lastTweetID: self.lastTweetID)
		}
		
		func replaceLastTweetID(lastTweetID: String?) -> TimelineInformation {
			
			return TimelineInformation(hashtag: self.hashtag, lastTweetID: lastTweetID)
		}
	}
	
	@IBOutlet weak var timelineTableView:NSTableView!
	@IBOutlet weak var timelineDataSource:TimelineTableDataSource!
	
	var timeline = TimelineInformation() {
		
		didSet {
			
			if self.timeline.hashtag != oldValue.hashtag {
				
				self.updateStatuses()
			}
			else {
				
				self.clearStatuses()
			}
		}
	}
}

// MARK: - View Control

extension TimelineViewController {

	override func viewDidLoad() {
        super.viewDidLoad()
		
		HashtagDidChangeNotification.observeBy(self) { owner, notification in
			
			let hashtag = notification.hashtag
			
			NSLog("Hashtag did change (\(hashtag))")
			
			owner.timeline = owner.timeline.replaceHashtag(hashtag)
		}
    }
	
	override func viewDidAppear() {

		super.viewDidAppear()
		
	}
}

// MARK: - Tweets control

extension TimelineViewController {
	
	private func updateStatuses() {
		
		let query = self.timeline.hashtag.description
		let lastTweetID = self.timeline.lastTweetID
		
		sns.twitter.getStatusesWithQuery(query, since: lastTweetID) { result in
			
			switch result {
				
			case .Success(let tweets) where !tweets.isEmpty:
				self.timelineDataSource.appendTweets(tweets)
				self.timelineTableView.reloadData()
				
			case .Success:
				break
				
			case .Failure(let error):
				self.showErrorAlert("Failed to get Timelines", message: error.localizedDescription)
			}
		}
	}
	
	private func clearStatuses() {
		
		self.timelineDataSource.tweets = []
		self.timelineTableView.reloadData()
	}
}

// MARK: - Table View Delegate

extension TimelineViewController : NSTableViewDelegate {

	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		guard let view = tableView.makeViewWithIdentifier("TimelineCell", owner: self) as? TimelineTableCellView else {
			
			return nil
		}
		
		view.status = self.timelineDataSource.tweets[row]
		
		return view
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		return self.timelineDataSource.estimateCellHeightOfRow(row)
	}
}
