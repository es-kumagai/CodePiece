//
//  TimelineViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim
import Ocean
import ESTwitter
import ESGists
import Dispatch

private let TableViewInsertAnimationOptions: NSTableView.AnimationOptions = [.slideDown, .effectFade]

class TimelineViewController: NSViewController {

	@IBOutlet var menuController: MenuController!
	
    var notificationHandlers = Notification.Handlers()
	
	@IBOutlet var cellForEstimateHeight: TimelineTableCellView!
	
	// Manage current selection by this property because selection indexes is reset when call insertRowsAtIndexes method for insert second cell.
	var currentTimelineSelectedRowIndexes = IndexSet() {
		
		willSet {
		
            willChangeValue(forKey: "canReplyRequest")
            willChangeValue(forKey: "canOpenBrowserWithCurrentTwitterStatus")
		}
		
		didSet {

			defer {
			
                didChangeValue(forKey: "canReplyRequest")
                didChangeValue(forKey: "canOpenBrowserWithCurrentTwitterStatus")
			}
			
			timelineTableView.makedCells.forEach { cell in
				
				cell.applySelection()
			}

			TimelineSelectionChangedNotification(timelineViewController: self, selectedCells: timelineTableView.selectedCells).post()
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
			
			precondition(Thread.isMainThread)
			
			self.updateDisplayControlsForState()
		}
	}
	
	private var autoUpdateState = AutoUpdateState()
	
	private(set) var message:MessageQueue<Message>!
	private var updateTimerSource: DispatchSourceTimer!
	
	var isTimelineActive: Bool {
	
		return true
	}
	
	var timeline = TimelineInformation() {
		
		didSet {
			
			if self.timeline.hashtags != oldValue.hashtags {
				
				self.message.send(message: .ChangeHashtags(self.timeline.hashtags))
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
		
		private var _updateInterval: Semaphore.Interval? = .init(nanosecond: 0)
		
		var updateInterval: Semaphore.Interval? {
			
			get {

				guard let updateInterval = _updateInterval else {
					
					return nil
				}
				
				return updateInterval + updateIntervalDelay
			}
			
			set {
				
				_updateInterval = newValue
			}
		}

		private(set) var updateIntervalDelay: Semaphore.Interval = .init(nanosecond: 0)
		var updateIntervalDelayMax: Semaphore.Interval = .init(nanosecond: 60)
		var nextUpdateTime: DispatchTime? = nil
		
		var isUpdateTimeOver:Bool {
		
			guard let nextUpdateTime = self.nextUpdateTime else {
				
				return false
			}
			
			return nextUpdateTime < DispatchTime.now()
		}
		
		mutating func setUpdated() {
			
			nextUpdateTime = nil
		}
		
		mutating func setNeedsUpdate() {
			
			guard updateInterval != nil else {

				nextUpdateTime = nil
				return
			}

			nextUpdateTime = DispatchTime.now()
		}
		
		mutating func updateNextUpdateTime() {
			
			guard let updateInterval = updateInterval else {
				
				nextUpdateTime = nil
				return
			}
				
			nextUpdateTime = DispatchTime.now() + updateInterval
		}
		
		mutating func resetUpdateIntervalDelay() {
			
			self.setUpdateIntervalDelayByInterval(interval: .zero)
		}

		mutating func addUpdateIntervalDelay(bySecond second: Double) {
			
			self.addUpdateIntervalDelayByInterval(interval: Semaphore.Interval(second: second))
		}

		mutating func setUpdateIntervalDelayBySecond(second: Double) {
			
            self.setUpdateIntervalDelayByInterval(interval: Semaphore.Interval(second: second))
		}
		
		mutating func addUpdateIntervalDelayByInterval(interval: Semaphore.Interval) {
			
			updateIntervalDelay = min(updateIntervalDelay + interval, updateIntervalDelayMax)
		}
		
		mutating func setUpdateIntervalDelayByInterval(interval: Semaphore.Interval) {
			
            updateIntervalDelay = interval
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
			self.message.send(message: .UpdateStatuses)
		}
	}
}

extension TimelineViewController : MessageQueueHandlerProtocol {
	
	func messageQueue(queue: MessageQueue<Message>, handlingMessage message: Message) throws {
		
		switch message {
			
		case .UpdateStatuses:
			self._updateStatuses()
			
		case .AutoUpdate(enable: let enable):
            self._changeAutoUpdateState(enable: enable)
			
		case .SetAutoUpdateInterval(let interval):
            self._changeAutoUpdateInterval(interval: interval)
			
		case .AddAutoUpdateIntervalDelay(let interval):
            self._changeAutoUpdateIntervalDelay(interval: interval)
			
		case .ResetAutoUpdateIntervalDeray:
			self._resetAutoUpdateIntervalDelay()
			
		case .SetReachability(let state):
            self._changeReachability(state: state)
			
		case .ChangeHashtags(let hashtags):
			self._changeHashtags(hashtags: hashtags)
		}
	}
	
	func messageQueue<Queue : MessageQueueType>(queue: Queue, handlingError error: Error) throws {
		
		fatalError(error.localizedDescription)
	}
	
	private func _updateStatuses() {
		
		self.autoUpdateState.updateNextUpdateTime()
		
		DispatchQueue.main.async(execute: updateStatuses)
	}
	
	private func _changeHashtags(hashtags: Set<ESTwitter.Hashtag>) {
		
		if timelineDataSource.appendHashtags(hashtags: hashtags).passed {
		
            DispatchQueue.main.sync {

                self.timelineTableView.insertRows(at: IndexSet(integer: 0), withAnimation: TableViewInsertAnimationOptions)
				self.message.send(message: .UpdateStatuses)
			}
		}
	}
	
	private func _changeAutoUpdateInterval(interval: Double) {
		
		autoUpdateState.updateInterval = Semaphore.Interval(second: interval)
	}
	
	private func _changeAutoUpdateIntervalDelay(interval: Double) {
		
		autoUpdateState.addUpdateIntervalDelay(bySecond: interval)
		
		NSLog("Next update of timeline will delay %@ seconds.", autoUpdateState.updateIntervalDelay.description)
	}
	
	private func _resetAutoUpdateIntervalDelay() {
		
		guard autoUpdateState.updateIntervalDelay != .zero else {
			
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
			
		case .viaWiFi, .viaCellular:
			NSLog("CodePiece has get internet connection.")
			self.autoUpdateState.hasInternetConnection = true
			self.autoUpdateState.setNeedsUpdate()
			
		case .unreachable:
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
		self.updateTimerSource = message.makeTimer(interval: Semaphore.Interval(second: 0.03), start: true, timerAction: self.autoUpdateAction)
		
		self.updateDisplayControlsForState()
		
		self.message.send(message: .SetAutoUpdateInterval(self.statusesAutoUpdateInterval))
		self.message.send(message: .SetReachability(NSApp.reachabilityController.state))
		self.message.send(message: .AutoUpdate(enable: true))
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
	
	}
	
	override func viewDidAppear() {

		super.viewDidAppear()
		
		self.observe(notification: Authorization.TwitterAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.message.send(message: .UpdateStatuses)
		}
		
		self.observe(notification: HashtagsDidChangeNotification.self) { [unowned self] notification in
			
			let hashtags = notification.hashtags
			
			NSLog("Hashtag did change (\(hashtags))")
			
			self.timeline = self.timeline.replaceHashtags(hashtags: hashtags)
		}
		
		self.observe(notificationNamed: NSWorkspace.willSleepNotification) { [unowned self] notification in
			
			self.message.send(message: .AutoUpdate(enable: false))
		}
		
		self.observe(notificationNamed: NSWorkspace.didWakeNotification) { [unowned self] notification in
			
			self.message.send(message: .AutoUpdate(enable: true))
		}
		
		self.observe(notification: ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] notification in
			
			self.message.send(message: .SetReachability(notification.state))
		}

		self.observe(notification: MainViewController.PostCompletelyNotification.self) { [unowned self] notification in
		
			DispatchQueue.main.async(after: 3.0) {
				
				self.message.send(message: .UpdateStatuses)
			}
		}
		
		self.message.send(message: .Start)
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		notificationHandlers.releaseAll()
		
		self.message.send(message: .Stop)
	}

	func reloadTimeline() {
		
		self.message.send(message: .UpdateStatuses)
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
			
			let result = self.appendTweets(tweets: tweets, hashtags: hashtags)
			let nextSelectedIndexes = self.getNextTimelineSelection(insertedIndexes: result.insertedIndexes)

			NSLog("Tweet: \(tweets.count)")
			NSLog("Inserted: \(result.insertedIndexes)")
			NSLog("Ignored: \(result.ignoredIndexes)")
			NSLog("Removed: \(result.removedIndexes)")
			
			self.currentTimelineSelectedRowIndexes = nextSelectedIndexes

			DebugTime.print("Next Selection:\n\tCurrentTimelineSelectedRows: \(self.currentTimelineSelectedRowIndexes)\n\tNative: \(self.timelineTableView.selectedRowIndexes)")
		}
		
		let gotTimelineSuccessfully = { () -> Void in
			
			self.message.send(message: .ResetAutoUpdateIntervalDeray)
			self.timelineStatusView.OKMessage = "Last Update: \(Date().displayString)"
		}
		
		let failedToGetTimeline = { (error: GetStatusesError) -> Void in
			
			if error.isRateLimitExceeded {
				
				self.message.send(message: .AddAutoUpdateIntervalDelay(7.0))
			}
		
            self.reportTimelineGetStatusError(error: error)
		}
		
		let getTimelineSpecifiedQuery = {
			
			self.displayControlState = .Updating
			
			NSApp.twitterController.getStatusesWithQuery(query: query, since: self.timelineDataSource.latestTweetIdForHashtags(hashtags: hashtags)) { result in
				
				self.displayControlState = .Updated

				switch result {
					
				case .success(let tweets) where !tweets.isEmpty:
					updateTable(tweets)
					gotTimelineSuccessfully()
					
				case .success:
					gotTimelineSuccessfully()
					
				case .failure(let error):
					failedToGetTimeline(error)
				}
			}
		}
		
		switch whether(condition: !query.isEmpty) {
			
		case true:
			getTimelineSpecifiedQuery()
			
		case false:
			break
		}
	}
}

// MARK: - Table View Delegate

extension TimelineViewController : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let items = self.timelineDataSource.items
		
		guard row < items.count else {
			
			return nil
		}
		
		let item = items[row]
        let cell = item.timelineCellType.makeCellWithItem(item: item, tableView: tableView, owner: self) as! TimelineTableCellType

//		cell.selected = tableView.isRowSelected(row)
        cell.selected = self.currentTimelineSelectedRowIndexes.contains(row)

		return cell.toTimelineView()
	}
	
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
        return self.timelineDataSource.estimateCellHeightOfRow(row: row, tableView: tableView)
	}

    private func tableViewSelectionIsChanging(notification: NSNotification) {
		
		guard let tableView = notification.object as? TimelineTableView, tableView === self.timelineTableView else {
			
			return
		}
	}
	
    private func tableViewSelectionDidChange(notification: NSNotification) {
		
		guard let tableView = notification.object as? TimelineTableView, tableView === self.timelineTableView else {
			
			return
		}
		
        currentTimelineSelectedRowIndexes = tableView.selectedRowIndexes
	}
}

