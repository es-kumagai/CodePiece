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
import ESNotification

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
	
	enum Message {
		
		case SetAutoUpdateInterval(Double)
		case SetReachability(ReachabilityController.State)
		case AutoUpdate(enable: Bool)
		case UpdateStatuses
	}
	
	@IBOutlet var timelineTableView:NSTableView!
	@IBOutlet var timelineDataSource:TimelineTableDataSource!
	
	let statusesAutoUpdateInterval:Double = 15
	
	private var autoUpdateState = AutoUpdateState()
	
	private(set) var message:MessageQueue<Message>!
	private var updateTimerSource:dispatch_source_t!
	
	var timeline = TimelineInformation() {
		
		didSet {
			
			if self.timeline.hashtag != oldValue.hashtag {
				
				self.timelineDataSource.tweets = []
				self.message.send(.UpdateStatuses)
			}
		}
	}
}

// MARK: - Message Handler

extension TimelineViewController {
	
	struct AutoUpdateState {
		
		var enabled:Bool = false {
		
			didSet {
				
				if self.enabled {
					
					self.setNeedsUpdate()
				}
			}
		}
		
		var hasInternetConnection:Bool = false
		
		var updateInterval:Int64 = 0
		var nextUpdateTime:dispatch_time_t? = nil
		
		var isUpdateTimeOver:Bool {
		
			guard let nextUpdateTime = self.nextUpdateTime else {
				
				return false
			}
			
			return nextUpdateTime < dispatch_time(DISPATCH_TIME_NOW, 0)
		}
		
		mutating func setUpdated() {
			
			self.nextUpdateTime = nil
		}
		
		mutating func setNeedsUpdate() {
			
			if self.updateInterval > 0 {
				
				self.nextUpdateTime = dispatch_time(DISPATCH_TIME_NOW, 0)
			}
			else {
				
				self.nextUpdateTime = nil
			}
		}
		
		mutating func updateNextUpdateTime() {
			
			if self.updateInterval > 0 {
				
				self.nextUpdateTime = dispatch_time(DISPATCH_TIME_NOW, self.updateInterval)
			}
			else {
				
				self.nextUpdateTime = nil
			}
		}
	}
	
	func autoUpdateAction() {
		
		guard self.autoUpdateState.enabled else {
			
			return
		}
		
		if self.autoUpdateState.isUpdateTimeOver {

			guard self.autoUpdateState.hasInternetConnection else {
				
				NSLog("No internet connection found.")
				self.autoUpdateState.updateNextUpdateTime()
				return
			}
			
			self.autoUpdateState.setUpdated()
			self.message.send(.UpdateStatuses)
		}
	}
}

extension TimelineViewController : MessageQueueHandlerProtocol {
	
	func messageQueue(queue: MessageQueue<Message>, handlingMessage message: Message) throws {
		
		switch message {
			
		case .UpdateStatuses:
			self._updateStatuses()
			
		case .AutoUpdate(enable: let enable):
			self._changeAutoUpdateState(enable)
			
		case .SetAutoUpdateInterval(let interval):
			self._changeAutoUpdateInterval(interval)
			
		case .SetReachability(let state):
			self._changeReachability(state)
		}
	}
	
	func messageQueue<Queue : MessageQueueType>(queue: Queue, handlingError error: ErrorType) throws {
		
		fatalError(String(error))
	}
	
	private func _updateStatuses() {
		
		self.autoUpdateState.updateNextUpdateTime()
		
		invokeAsyncOnMainQueue(self.updateStatuses)
	}
	
	private func _changeAutoUpdateInterval(interval: Double) {
		
		self.autoUpdateState.updateInterval = Semaphore.Interval(second: interval).rawValue
	}
	
	private func _changeAutoUpdateState(enable: Bool) {
		
		self.autoUpdateState.enabled = enable
		NSLog("Timeline update automatically is \(enable)d.")
		
		if enable {
			
			self.autoUpdateState.setNeedsUpdate()
		}
	}
	
	private func _changeReachability(state: ReachabilityController.State) {
		
		switch state {
			
		case .ViaWiFi, .ViaCellular:
			NSLog("CodePiece has get internet connection.")
			self.autoUpdateState.hasInternetConnection = true
			self.autoUpdateState.setNeedsUpdate()
			
		case .Unreachable:
			NSLog("CodePiece has lost internet connection.")
			self.autoUpdateState.hasInternetConnection = false
		}
	}
}

// MARK: - View Control

extension TimelineViewController {

	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.message = MessageQueue(identifier: "CodePiece.Timeline", handler: self)
		self.updateTimerSource = self.message.makeTimer(Semaphore.Interval(second: 0.03), start: true, timerAction: self.autoUpdateAction)
		
		Authorization.TwitterAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
		
			self.message.send(.UpdateStatuses)
		}
		
		HashtagDidChangeNotification.observeBy(self) { owner, notification in
			
			let hashtag = notification.hashtag
			
			NSLog("Hashtag did change (\(hashtag))")
			
			owner.timeline = owner.timeline.replaceHashtag(hashtag)
		}
		
		NamedNotification.observe(NSWorkspaceWillSleepNotification, by: self) { owner, notification in
			
			self.message.send(.AutoUpdate(enable: false))
		}
		
		NamedNotification.observe(NSWorkspaceDidWakeNotification, by: self) { owner, notification in
		
			self.message.send(.AutoUpdate(enable: true))
		}

		ReachabilityController.ReachabilityChangedNotification.observeBy(self) { observer, notification in
			
			self.message.send(.SetReachability(notification.state))
		}
		
		self.message.send(.SetAutoUpdateInterval(self.statusesAutoUpdateInterval))
		self.message.send(.SetReachability(NSApp.reachabilityController.state))
		self.message.send(.AutoUpdate(enable: true))
    }
	
	override func viewDidAppear() {

		super.viewDidAppear()
		
		self.message.send(.Start)
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		self.message.send(.Stop)
	}
}

// MARK: - Tweets control

extension TimelineViewController {
		
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
