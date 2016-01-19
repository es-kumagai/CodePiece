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
import ESGists

private let TableViewInsertAnimationOptions: NSTableViewAnimationOptions = [.SlideDown, .EffectFade]

class TimelineViewController: NSViewController {

	var notificationHandlers = NotificationHandlers()
	
	@IBOutlet var cellForEstimateHeight: TimelineTableCellView!
	
	// Manage current selection by this property because selection indexes is reset when call insertRowsAtIndexes method for insert second cell.
	var currentTimelineSelectedRowIndexes = NSIndexSet() {
		
		willSet {
		
			willChangeValueForKey("canReplyRequest")
		}
		
		didSet {

			defer {
			
				didChangeValueForKey("canReplyRequest")
			}
			
			let tableView = self.timelineTableView

			tableView.makedCells.forEach { cell in
				
				cell.applySelection()
			}

			TimelineSelectionChangedNotification(timelineViewController: self, selectedCells: tableView.selectedCells).post()
		}
	}
	
	struct TimelineInformation {
	
		var hashtags: ESTwitter.HashtagSet
		
		init() {
		
			self.init(hashtags: [""])
		}
		
		init(hashtags: ESTwitter.HashtagSet) {
			
			self.hashtags = hashtags
		}
		
		func replaceHashtags(hashtags: ESTwitter.HashtagSet) -> TimelineInformation {
			
			return TimelineInformation(hashtags: hashtags)
		}
	}
	
	enum Message : MessageTypeIgnoreInQuickSuccession {
		
		case SetAutoUpdateInterval(Double)
		case AddAutoUpdateIntervalDelay(Double)
		case ResetAutoUpdateIntervalDeray
		case SetReachability(ReachabilityController.State)
		case AutoUpdate(enable: Bool)
		case UpdateStatuses
		case ChangeHashtags(Set<ESTwitter.Hashtag>)
		
		func blockInQuickSuccession(lastMessage: Message) -> Bool {
			
			switch (self, lastMessage) {
				
			case (.UpdateStatuses, .UpdateStatuses):
				return true
				
			default:
				return false
			}
		}
	}

	@IBOutlet var timelineTableView:TimelineTableView!
	@IBOutlet var timelineDataSource:TimelineTableDataSource!
	@IBOutlet var timelineStatusView: TimelineStatusView! {
		
		didSet {
			
			self.timelineStatusView.clearMessage()
		}
	}
	
	@IBOutlet var timelineUpdateIndicator: NSProgressIndicator? {
	
		didSet {
			
			self.timelineUpdateIndicator?.usesThreadedAnimation = true
		}
	}
	
	@IBOutlet var timelineRefreshButton: NSButton?
	
	let statusesAutoUpdateInterval:Double = 20
	
	private(set) var displayControlState = DisplayControlState.Updated {
		
		didSet {
			
			precondition(NSThread.isMainThread())
			
			self.updateDisplayControlsForState()
		}
	}
	
	private var autoUpdateState = AutoUpdateState()
	
	private(set) var message:MessageQueue<Message>!
	private var updateTimerSource:dispatch_source_t!
	
	var isTimelineActive: Bool {
	
		return true
	}
	
	var timeline = TimelineInformation() {
		
		didSet {
			
			if self.timeline.hashtags != oldValue.hashtags {
				
				self.message.send(.ChangeHashtags(self.timeline.hashtags))
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
		
		private var _updateInterval:Int64 = 0
		
		var updateInterval:Int64 {
			
			get {
				
				return self._updateInterval + self.updateIntervalDelay
			}
			
			set {
				
				self._updateInterval = newValue
			}
		}

		private(set) var updateIntervalDelay:Int64 = 0
		var updateIntervalDelayMax:Int64 = 60
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
		
		mutating func resetUpdateIntervalDelay() {
			
			self.setUpdateIntervalDelay(0)
		}

		mutating func addUpdateIntervalDelayBySecond(second: Double) {
			
			self.addUpdateIntervalDelayByInterval(Semaphore.Interval(second: second))
		}

		mutating func addUpdateIntervalDelayByInterval(interval: Semaphore.Interval) {
			
			self.addUpdateIntervalDelay(interval.rawValue)
		}
		
		mutating func setUpdateIntervalDelayBySecond(second: Double) {
			
			self.setUpdateIntervalDelayByInterval(Semaphore.Interval(second: second))
		}
		
		mutating func setUpdateIntervalDelayByInterval(interval: Semaphore.Interval) {
			
			self.setUpdateIntervalDelay(interval.rawValue)
		}

		mutating func addUpdateIntervalDelay(delay: Int64) {
			
			self.updateIntervalDelay = min(self.updateIntervalDelay + delay, self.updateIntervalDelayMax)
		}
		
		mutating func setUpdateIntervalDelay(delay: Int64) {
			
			self.updateIntervalDelay = delay
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
			
		case .AddAutoUpdateIntervalDelay(let interval):
			self._changeAutoUpdateIntervalDelay(interval)
			
		case .ResetAutoUpdateIntervalDeray:
			self._resetAutoUpdateIntervalDelay()
			
		case .SetReachability(let state):
			self._changeReachability(state)
			
		case .ChangeHashtags(let hashtags):
			self._changeHashtags(hashtags)
		}
	}
	
	func messageQueue<Queue : MessageQueueType>(queue: Queue, handlingError error: ErrorType) throws {
		
		fatalError(String(error))
	}
	
	private func _updateStatuses() {
		
		self.autoUpdateState.updateNextUpdateTime()
		
		invokeAsyncOnMainQueue(self.updateStatuses)
	}
	
	private func _changeHashtags(hashtags: Set<ESTwitter.Hashtag>) {
		
		if self.timelineDataSource.appendHashtags(hashtags) {
		
			invokeOnMainQueue {

				self.timelineTableView.insertRowsAtIndexes(NSIndexSet(index: 0), withAnimation: TableViewInsertAnimationOptions)
				self.message.send(.UpdateStatuses)
			}
		}
	}
	
	private func _changeAutoUpdateInterval(interval: Double) {
		
		self.autoUpdateState.updateInterval = Semaphore.Interval(second: interval).rawValue
	}
	
	private func _changeAutoUpdateIntervalDelay(interval: Double) {
		
		self.autoUpdateState.addUpdateIntervalDelayBySecond(interval)
		
		NSLog("Next update of timeline will delay %@ seconds.", Semaphore.Interval(rawValue: self.autoUpdateState.updateIntervalDelay).description)
	}
	
	private func _resetAutoUpdateIntervalDelay() {
		
		guard self.autoUpdateState.updateIntervalDelay.isNonZero else {
			
			return
		}
		
		self.autoUpdateState.resetUpdateIntervalDelay()
		NSLog("Delay for update of timeline was solved.")
	}
	
	private func _changeAutoUpdateState(enable: Bool) {
		
		self.autoUpdateState.enabled = enable
		NSLog("Timeline update automatically is \(enable ? "enabled" : "disabled").")
		
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

extension TimelineViewController : NotificationObservable {

	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.message = MessageQueue(identifier: "CodePiece.Timeline", handler: self)
		self.updateTimerSource = self.message.makeTimer(Semaphore.Interval(second: 0.03), start: true, timerAction: self.autoUpdateAction)
		
		self.updateDisplayControlsForState()
		
		self.message.send(.SetAutoUpdateInterval(self.statusesAutoUpdateInterval))
		self.message.send(.SetReachability(NSApp.reachabilityController.state))
		self.message.send(.AutoUpdate(enable: true))
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
	
	}
	
	override func viewDidAppear() {

		super.viewDidAppear()
		
		self.observeNotification(Authorization.TwitterAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.message.send(.UpdateStatuses)
		}
		
		self.observeNotification(HashtagsDidChangeNotification.self) { [unowned self] notification in
			
			let hashtags = notification.hashtags
			
			NSLog("Hashtag did change (\(hashtags))")
			
			self.timeline = self.timeline.replaceHashtags(hashtags)
		}
		
		self.observeNotificationNamed(NSWorkspaceWillSleepNotification) { [unowned self] notification in
			
			self.message.send(.AutoUpdate(enable: false))
		}
		
		self.observeNotificationNamed(NSWorkspaceDidWakeNotification) { [unowned self] notification in
			
			self.message.send(.AutoUpdate(enable: true))
		}
		
		self.observeNotification(ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] notification in
			
			self.message.send(.SetReachability(notification.state))
		}

		self.observeNotification(ViewController.PostCompletelyNotification.self) { [unowned self] notification in
		
			invokeAsyncOnMainQueue(after: 3.0) {
				
				self.message.send(.UpdateStatuses)
			}
		}
		
		self.message.send(.Start)
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		self.releaseAllObservingNotifications()
		
		self.message.send(.Stop)
	}

	func reloadTimeline() {
		
		self.message.send(.UpdateStatuses)
	}
}

// MARK: - Tweets control

extension TimelineViewController : TimelineTableControllerType {
	
}

extension TimelineViewController : TimelineGetStatusesController {
	
	private func updateStatuses() {
		
		guard NSApp.twitterController.credentialsVerified else {
		
			NSLog("Cancel update for twitter timeline because current twitter account's credentials is not verified.")
			return
		}
		
		let hashtags = self.timeline.hashtags
		let query = hashtags.toTwitterQueryText()
		
		let updateTable = { (tweets:[Status]) in
			
			DebugTime.print("Current Selection:\n\tCurrentTimelineSelectedRows: \(self.currentTimelineSelectedRowIndexes)\n\tNative: \(self.timelineTableView.selectedRowIndexes)")
			
			let result = self.appendTweets(tweets, hashtags: hashtags)
			let nextSelectedIndexes = self.getNextTimelineSelection(result.insertedIndexes)

			NSLog("Tweet: \(tweets.count)")
			NSLog("Inserted: \(result.insertedIndexes)")
			NSLog("Ignored: \(result.ignoredIndexes)")
			NSLog("Removed: \(result.removedIndexes)")
			
			self.currentTimelineSelectedRowIndexes = nextSelectedIndexes

			DebugTime.print("Next Selection:\n\tCurrentTimelineSelectedRows: \(self.currentTimelineSelectedRowIndexes)\n\tNative: \(self.timelineTableView.selectedRowIndexes)")
		}
		
		let gotTimelineSuccessfully = { () -> Void in
			
			self.message.send(.ResetAutoUpdateIntervalDeray)
			self.timelineStatusView.OKMessage = "Last Update: \(NSDate().displayString)"
		}
		
		let failedToGetTimeline = { (error: GetStatusesError) -> Void in
						
			if case .RateLimitExceeded = error.type {
				
				self.message.send(.AddAutoUpdateIntervalDelay(7.0))
			}
		
			self.reportTimelineGetStatusError(error)
		}
		
		let getTimelineSpecifiedQuery = {
			
			self.displayControlState = .Updating
			
			NSApp.twitterController.getStatusesWithQuery(query, since: self.timelineDataSource.latestTweetIdForHashtags(hashtags)) { result in
				
				self.displayControlState = .Updated

				switch result {
					
				case .Success(let tweets) where !tweets.isEmpty:
					updateTable(tweets)
					gotTimelineSuccessfully()
					
				case .Success:
					gotTimelineSuccessfully()
					
				case .Failure(let error):
					failedToGetTimeline(error)
				}
			}
		}
		
		switch whether(!query.isEmpty) {
			
		case .Yes:
			getTimelineSpecifiedQuery()
			
		case .No:
			break
		}
	}
}

// MARK: - Table View Delegate

extension TimelineViewController : NSTableViewDelegate {

	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let items = self.timelineDataSource.items
		
		guard row < items.count else {
			
			return nil
		}
		
		let item = items[row]
		let cell = item.timelineCellType.makeCellWithItem(item, tableView: tableView, owner: self) as! TimelineTableCellType

//		cell.selected = tableView.isRowSelected(row)
		cell.selected = self.currentTimelineSelectedRowIndexes.containsIndex(row)

		return cell.toTimelineView()
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		return self.timelineDataSource.estimateCellHeightOfRow(row, tableView: tableView)
	}

	func tableViewSelectionIsChanging(notification: NSNotification) {
		
		guard let tableView = notification.object as? TimelineTableView where tableView === self.timelineTableView else {
			
			return
		}
	}
	
	func tableViewSelectionDidChange(notification: NSNotification) {
		
		guard let tableView = notification.object as? TimelineTableView where tableView === self.timelineTableView else {
			
			return
		}
		
		currentTimelineSelectedRowIndexes = tableView.selectedRowIndexes
	}
}
