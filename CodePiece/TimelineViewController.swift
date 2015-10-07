//
//  TimelineViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim
import ESThread
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
	
	private var _statusesAutoLoadThread:NSThread?
	let statusesAutoUpdateInterval:NSTimeInterval = 15
	
	var timeline = TimelineInformation() {
		
		didSet {
			
			if self.timeline.hashtag != oldValue.hashtag {
				
				self.updateStatuses()
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
		
		self._statusesAutoLoadThread.ifHasValue {
		
			$0.cancel()
		}
		
		self._statusesAutoLoadThread = tweak(NSThread(target: self, selector: "updateStatusTimerAction:", object: nil)){
			
			$0.start()
		}
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		self._statusesAutoLoadThread?.cancel()
	}
}

// MARK: - Tweets control

extension TimelineViewController {
	
	func updateStatusTimerAction(object: AnyObject?) {
		
		NSLog("Start updating twitter timeline automatically.")
		
		let thread = NSThread.currentThread()
		
		while !thread.cancelled {
			
			invokeOnMainQueue {
				
				self.updateStatuses()
			}
			
			NSThread.sleepForTimeInterval(self.statusesAutoUpdateInterval)
		}
		
		NSLog("Stop updating twitter timeline.")
	}
	
	private func updateStatuses() {
		
		let query = self.timeline.hashtag.description
		let lastTweetID = self.timeline.lastTweetID
		
		let getTimelineSpecifiedQuery = {
			
			sns.twitter.getStatusesWithQuery(query, since: lastTweetID) { result in
				
				switch result {
					
				case .Success(let tweets) where !tweets.isEmpty:

					self.timeline.lastTweetID = tweets.first!.idStr
					self.timelineDataSource.appendTweets(tweets)
					self.timelineTableView.reloadData()
					
				case .Success:
					break
					
				case .Failure(let error):
					self.showErrorAlert("Failed to get Timelines", message: error.localizedDescription)
				}
			}
		}
		
		let clearTimeline = {
			
			self.clearStatuses()
		}
		
		switch whether(!query.isEmpty) {
			
		case .Yes:
			getTimelineSpecifiedQuery()
			
		case .No:
			clearTimeline()
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
		
		let view = tweak(tableView.makeViewWithIdentifier("TimelineCell", owner: self) as! TimelineTableCellView) {
			
			$0.status = self.timelineDataSource.tweets[row]
		}
		
		return view
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		return self.timelineDataSource.estimateCellHeightOfRow(row, tableView: tableView)
	}
}
