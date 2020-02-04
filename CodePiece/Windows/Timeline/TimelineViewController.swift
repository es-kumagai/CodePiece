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

@objcMembers
final class TimelineViewController: NSViewController {

	@IBOutlet var menuController: MenuController!
	@IBOutlet var timelineKindStateController: TimelineKindStateController!
	
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
			
			for cell in timelineTableView.makedCells {
				
				cell.applySelection()
			}

			TimelineSelectionChangedNotification(timelineViewController: self, selectedCells: timelineTableView.selectedCells).post()
		}
	}
	
	struct TimelineInformation {
	
		var hashtags: HashtagSet
		
		init() {
		
			self.init(hashtags: [])
		}
		
		init(hashtags: HashtagSet) {
			
			self.hashtags = hashtags
		}
		
		func replaceHashtags(hashtags: HashtagSet) -> TimelineInformation {
			
			defer {
				NSLog("Hashtag did change: \(hashtags)")
			}
			
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
		case ChangeHashtags(HashtagSet)
		
		func blockInQuickSuccession(lastMessage: Message) -> Bool {
			
			switch (self, lastMessage) {
				
			case (.UpdateStatuses, .UpdateStatuses):
				return true
				
			default:
				return false
			}
		}
	}

	@IBOutlet var timelineTableView: TimelineTableView!
	@IBOutlet var timelineDataSource: TimelineTableDataSource!
	@IBOutlet var timelineStatusView: TimelineStatusView! {
		
		didSet {
			
			timelineStatusView.clearMessage()
		}
	}
	
	@IBOutlet var timelineUpdateIndicator: NSProgressIndicator? {
	
		didSet {
			
			timelineUpdateIndicator?.usesThreadedAnimation = true
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
	
	private(set) var message: MessageQueue<Message>!
	private var updateTimerSource: DispatchSourceTimer!
	
	var isTimelineActive: Bool {
	
		return true
	}
	
	var timeline = TimelineInformation(hashtags: NSApp.settings.appState.hashtags ?? []) {
		
		didSet {
			
			if timeline.hashtags != oldValue.hashtags {
				
				message.send(message: .ChangeHashtags(timeline.hashtags))
			}
		}
	}
}

// MARK: - Message Handler

extension TimelineViewController {
	
	struct AutoUpdateState {
		
		var enabled: Bool = false {
		
			didSet {
				
				if enabled {
					
					setNeedsUpdate()
				}
			}
		}
		
		var hasInternetConnection: Bool = false
		
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
		
		var isUpdateTimeOver: Bool {
		
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
			
			setUpdateIntervalDelayByInterval(interval: .zero)
		}

		mutating func addUpdateIntervalDelay(bySecond second: Double) {
			
			addUpdateIntervalDelayByInterval(interval: Semaphore.Interval(second: second))
		}

		mutating func setUpdateIntervalDelayBySecond(second: Double) {
			
            setUpdateIntervalDelayByInterval(interval: Semaphore.Interval(second: second))
		}
		
		mutating func addUpdateIntervalDelayByInterval(interval: Semaphore.Interval) {
			
			updateIntervalDelay = min(updateIntervalDelay + interval, updateIntervalDelayMax)
		}
		
		mutating func setUpdateIntervalDelayByInterval(interval: Semaphore.Interval) {
			
            updateIntervalDelay = interval
		}
	}
	
	func autoUpdateAction() {
				
		guard autoUpdateState.enabled else {
			
			return
		}
		
		if autoUpdateState.isUpdateTimeOver {

			guard autoUpdateState.hasInternetConnection else {
				
				NSLog("No internet connection found.")
				autoUpdateState.updateNextUpdateTime()
				return
			}
			
			autoUpdateState.setUpdated()
			message.send(message: .UpdateStatuses)
		}
	}
}

extension TimelineViewController : MessageQueueHandlerProtocol {
	
	func messageQueue(queue: MessageQueue<Message>, handlingMessage message: Message) throws {
		
		switch message {
			
		case .UpdateStatuses:
			_updateStatuses()
			
		case .AutoUpdate(enable: let enable):
            _changeAutoUpdateState(enable: enable)
			
		case .SetAutoUpdateInterval(let interval):
            _changeAutoUpdateInterval(interval: interval)
			
		case .AddAutoUpdateIntervalDelay(let interval):
            _changeAutoUpdateIntervalDelay(interval: interval)
			
		case .ResetAutoUpdateIntervalDeray:
			_resetAutoUpdateIntervalDelay()
			
		case .SetReachability(let state):
            _changeReachability(state: state)
			
		case .ChangeHashtags(let hashtags):
			_changeHashtags(hashtags: hashtags)
		}
	}
	
	func messageQueue<Queue : MessageQueueType>(queue: Queue, handlingError error: Error) throws {
		
		fatalError(error.localizedDescription)
	}
	
	private func _updateStatuses() {
		
		autoUpdateState.updateNextUpdateTime()
		
		DispatchQueue.main.async(execute: updateStatuses)
	}
	
	private func _changeHashtags(hashtags: Set<Hashtag>) {
		
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
		
		autoUpdateState.resetUpdateIntervalDelay()
		NSLog("Delay for update of timeline was solved.")
	}
	
	private func _changeAutoUpdateState(enable: Bool) {
		
		autoUpdateState.enabled = enable
		NSLog("Timeline update automatically is \(enable ? "enabled" : "disabled").")
		
		if enable {
			
			autoUpdateState.setNeedsUpdate()
		}
	}
	
	private func _changeReachability(state: ReachabilityController.State) {
		
		switch state {
			
		case .viaWiFi, .viaCellular:
			NSLog("CodePiece has get internet connection.")
			autoUpdateState.hasInternetConnection = true
			autoUpdateState.setNeedsUpdate()
			
		case .unreachable:
			NSLog("CodePiece has lost internet connection.")
			autoUpdateState.hasInternetConnection = false
		}
	}
}

// MARK: - View Control

extension TimelineViewController : NotificationObservable {

	override func awakeFromNib() {
		
		super.awakeFromNib()
	}
	
	override func viewDidLoad() {
		
        super.viewDidLoad()
		
		message = MessageQueue(identifier: "CodePiece.Timeline", handler: self)
		updateTimerSource = message.makeTimerSource(interval: Semaphore.Interval(second: 0.03), start: true, timerAction: autoUpdateAction)
		
		
		updateDisplayControlsForState()
		
		message.send(message: .SetAutoUpdateInterval(statusesAutoUpdateInterval))
		message.send(message: .SetReachability(NSApp.reachabilityController.state))
		message.send(message: .AutoUpdate(enable: true))
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
	
		observe(notification: TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.message.send(message: .UpdateStatuses)
		}
		
		observe(notification: HashtagsDidChangeNotification.self) { [unowned self] notification in
			
			self.timeline = self.timeline.replaceHashtags(hashtags: notification.hashtags)
		}
		
		observe(notificationNamed: NSWorkspace.willSleepNotification) { [unowned self] notification in
			
			self.message.send(message: .AutoUpdate(enable: false))
		}
		
		observe(notificationNamed: NSWorkspace.didWakeNotification) { [unowned self] notification in
			
			self.message.send(message: .AutoUpdate(enable: true))
		}
		
		observe(notification: ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] notification in
			
			self.message.send(message: .SetReachability(notification.state))
		}

		observe(notification: MainViewController.PostCompletelyNotification.self) { [unowned self] notification in
		
			DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
				
				self.message.send(message: TimelineViewController.Message.UpdateStatuses)
			}
		}

		message.send(message: .Start)
	}
	
	override func viewDidAppear() {

		super.viewDidAppear()
	
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		notificationHandlers.releaseAll()
		
		message.send(message: .Stop)
	}

	func reloadTimeline() {
		
		message.send(message: .UpdateStatuses)
	}
}

// MARK: - Tweets control

extension TimelineViewController : TimelineTableControllerType {

}

extension TimelineViewController : TimelineGetStatusesController {
	
	private func updateStatuses() {
		
		guard NSApp.twitterController.readyToUse else {
		
			return
		}
		
		let hashtags = timeline.hashtags
		let query = hashtags.twitterQueryText
		
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
		
		let failedToGetTimeline = { (error: PostError) -> Void in
			
//			if error.isRateLimitExceeded {
//				
//				self.message.send(message: .AddAutoUpdateIntervalDelay(7.0))
//			}
		
            self.reportTimelineGetStatusError(error: error)
		}
		
		let getTimelineSpecifiedQuery = {
			
			self.displayControlState = .Updating
			
			let options = API.SearchOptions(
				sinceId: self.timelineDataSource.latestTweetIdForHashtags(hashtags: hashtags)
			)
			
			NSApp.twitterController.search(tweetWith: query, options: options) { result in
				
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
		
		switch !query.isEmpty {
			
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
		
		let items = timelineDataSource.items
		
		guard row < items.count else {
			
			return nil
		}
		
		let item = items[row]
        let cell = item.timelineCellType.makeCellWithItem(item: item, tableView: tableView, owner: self) as! TimelineTableCellType

//		cell.selected = tableView.isRowSelected(row)
        cell.selected = currentTimelineSelectedRowIndexes.contains(row)

		return cell.toTimelineView()
	}

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
        return self.timelineDataSource.estimateCellHeightOfRow(row: row, tableView: tableView)
	}

    func tableViewSelectionIsChanging(_ notification: Notification) {
		
		guard let tableView = notification.object as? TimelineTableView, tableView === timelineTableView else {
			
			return
		}
	}
	
    func tableViewSelectionDidChange(_ notification: Notification) {
		
		guard let tableView = notification.object as? TimelineTableView, tableView === timelineTableView else {
			
			return
		}
		
        currentTimelineSelectedRowIndexes = tableView.selectedRowIndexes
	}
}

extension TimelineViewController : TimelineKindStateDelegate {
	
	func timelineKindStateChanged(_ sender: TimelineKindStateController, kind: TimelineKindStateController.TimelineKind) {
		
		print(kind.description)
	}
}
