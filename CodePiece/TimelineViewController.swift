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
		
		init() {
		
			self.init(hashtag: "")
		}
		
		init(hashtag: ESTwitter.Hashtag) {
			
			self.hashtag = hashtag
		}
		
		func replaceHashtag(hashtag: ESTwitter.Hashtag) -> TimelineInformation {
			
			return TimelineInformation(hashtag: hashtag)
		}
	}
	
	@IBOutlet weak var timelineTableView:NSTableView!	
	@IBOutlet weak var timelineDataSource:TimelineTableDataSource!
	
	private var _statusesAutoLoadThread:NSThread?
	let statusesAutoUpdateInterval:NSTimeInterval = 15
	
	var timeline = TimelineInformation() {
		
		didSet {
			
			if self.timeline.hashtag != oldValue.hashtag {
				
				self.timelineDataSource.tweets = []
				self.updateStatuses()
			}
		}
	}
}

// MARK: - View Control

extension TimelineViewController {

	override func viewDidLoad() {
        super.viewDidLoad()
		
		Authorization.TwitterAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
		
			self.updateStatuses()
		}
		
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
		
		guard NSApp.twitterController.credentialsVerified else {
		
			NSLog("Cancel update for twitter timeline because current twitter account's credentials is not verified.")
			return
		}
		
		let query = self.timeline.hashtag.description
		
		let updateTable = { (tweets:[Status]) in

			let getNextSelection:()->Int = {
				
				let next = self.timelineTableView.selectedRow + tweets.count
				let maxRows = self.timelineDataSource.maxTweets
				
				if next < maxRows {
					
					return next
				}
				else {
					
					return -1
				}
			}
			
			let nextSelection = getNextSelection()
//			let updateRange = NSIndexSet(indexesInRange: NSMakeRange(0, tweets.count.predecessor()))

			self.timelineDataSource.appendTweets(tweets)

//			self.timelineTableView.insertRowsAtIndexes(updateRange, withAnimation: [.SlideUp, .EffectFade])
			self.timelineTableView.reloadData()
			self.timelineTableView.selectRowIndexes(NSIndexSet(index: nextSelection), byExtendingSelection: false)
		}
		
		let getTimelineSpecifiedQuery = {
			
			NSApp.twitterController.getStatusesWithQuery(query, since: self.timelineDataSource.lastTweetID) { result in
				
				switch result {
					
				case .Success(let tweets) where !tweets.isEmpty:
					updateTable(tweets)
					
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
		
		let tweets = self.timelineDataSource.tweets
		
		guard row < tweets.count else {
			
			return nil
		}
		
		let view = tweak(tableView.makeViewWithIdentifier("TimelineCell", owner: self) as! TimelineTableCellView) {
			
			$0.textLabel.selectable = false
			$0.status = tweets[row]
		}
		
		return view
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		return self.timelineDataSource.estimateCellHeightOfRow(row, tableView: tableView)
	}
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		
		guard let tableView = notification.object as? TimelineTableView where tableView === self.timelineTableView else {
			
			return
		}
		
		let selectedIndexes = tableView.selectedRowIndexes
		
		for row in 0 ..< tableView.numberOfRows {
		
			if let cell = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? TimelineTableCellView {
				
				cell.selected = selectedIndexes.containsIndex(row)
			}
		}
	}
}
