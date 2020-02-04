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
	
	@IBOutlet var timelineKindStateController: TimelineKindStateController! {
		
		didSet {
			
			#warning("検証用に既定値を変更します。")
			timelineKindStateController.timelineKind = .myTweets
		}
	}
	
	var currentTimelineKind: TimelineKind? {
		
		return timelineKindStateController.timelineKind
	}
	
	var notificationHandlers = Notification.Handlers()
	
	@IBOutlet var cellForEstimateHeight: TimelineTableCellView!
	
	@IBOutlet var hashtagsContentsController: HashtagsContentsController!
	@IBOutlet var myTweetsContentsController: MyTweetsContentsController!
	
	
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
	
	enum Message : MessageTypeIgnoreInQuickSuccession {
		
		case setAutoUpdateInterval(Double)
		case addAutoUpdateIntervalDelay(Double)
		case resetAutoUpdateIntervalDeray
		case setReachability(ReachabilityController.State)
		case autoUpdate(enable: Bool)
		case updateStatuses
		//		case changeHashtags(HashtagSet)
		
		func blockInQuickSuccession(lastMessage: Message) -> Bool {
			
			switch (self, lastMessage) {
				
			case (.updateStatuses, .updateStatuses):
				return true
				
			default:
				return false
			}
		}
	}
	
	@IBOutlet var timelineTableView: TimelineTableView!
	@IBOutlet var timelineStatusView: TimelineStatusView! {
		
		didSet {
			
			timelineStatusView.clearMessage()
		}
	}
	
	var activeTimelineContentsController: TimelineContentsController {
		
		switch currentTimelineKind {
			
		case .hashtags:
			return hashtagsContentsController
			
		case .myTweets:
			return myTweetsContentsController
			
		case .none:
			fatalError("Timeline kind is not specified.")
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
}

extension TimelineViewController {
	
	func updateTimeline() {
		
		activeTimelineContentsController.tableView = timelineTableView
		activeTimelineContentsController.updateContents()
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
			message.send(message: .updateStatuses)
		}
	}
}

extension TimelineViewController : MessageQueueHandlerProtocol {
	
	func messageQueue(queue: MessageQueue<Message>, handlingMessage message: Message) throws {
		
		switch message {
			
		case .updateStatuses:
			_updateStatuses()
			
		case .autoUpdate(enable: let enable):
			_changeAutoUpdateState(enable: enable)
			
		case .setAutoUpdateInterval(let interval):
			_changeAutoUpdateInterval(interval: interval)
			
		case .addAutoUpdateIntervalDelay(let interval):
			_changeAutoUpdateIntervalDelay(interval: interval)
			
		case .resetAutoUpdateIntervalDeray:
			_resetAutoUpdateIntervalDelay()
			
		case .setReachability(let state):
			_changeReachability(state: state)
			
			//		case .changeHashtags(let hashtags):
			//			_changeHashtags(hashtags: hashtags)
		}
	}
	
	func messageQueue<Queue : MessageQueueType>(queue: Queue, handlingError error: Error) throws {
		
		fatalError(error.localizedDescription)
	}
	
	private func _updateStatuses() {
		
		autoUpdateState.updateNextUpdateTime()
		
		DispatchQueue.main.async(execute: updateStatuses)
	}
	
	//	private func _changeHashtags(hashtags: Set<Hashtag>) {
	//
	//		if activeDataSource.appendHashtags(hashtags: hashtags).passed {
	//
	//            DispatchQueue.main.sync {
	//
	//                self.timelineTableView.insertRows(at: IndexSet(integer: 0), withAnimation: TableViewInsertAnimationOptions)
	//				self.message.send(message: .updateStatuses)
	//			}
	//		}
	//	}
	
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
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		message = MessageQueue(identifier: "CodePiece.Timeline", handler: self)
		updateTimerSource = message.makeTimerSource(interval: Semaphore.Interval(second: 0.03), start: true, timerAction: autoUpdateAction)
		
		
		updateDisplayControlsForState()
		
		message.send(message: .setAutoUpdateInterval(statusesAutoUpdateInterval))
		message.send(message: .setReachability(NSApp.reachabilityController.state))
		message.send(message: .autoUpdate(enable: true))
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		hashtagsContentsController.activate()
		myTweetsContentsController.activate()
		
		observe(notification: TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.message.send(message: .updateStatuses)
		}
		
		observe(notificationNamed: NSWorkspace.willSleepNotification) { [unowned self] notification in
			
			self.message.send(message: .autoUpdate(enable: false))
		}
		
		observe(notificationNamed: NSWorkspace.didWakeNotification) { [unowned self] notification in
			
			self.message.send(message: .autoUpdate(enable: true))
		}
		
		observe(notification: ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] notification in
			
			self.message.send(message: .setReachability(notification.state))
		}
		
		observe(notification: MainViewController.PostCompletelyNotification.self) { [unowned self] notification in
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
				
				self.message.send(message: TimelineViewController.Message.updateStatuses)
			}
		}
		
		message.send(message: .Start)
	}
	
	override func viewDidAppear() {
		
		super.viewDidAppear()
		
		updateTimeline()
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		notificationHandlers.releaseAll()
		
		message.send(message: .Stop)
	}
	
	func reloadTimeline() {
		
		message.send(message: .updateStatuses)
	}
}

// MARK: - Tweets control

// FIXME: TimelineTableControllerType で実装していたもの。動作できたら正式にここに残します。
extension TimelineViewController {
	
	var currentTimelineRows: Int {
		
		return timelineTableView.numberOfRows
	}
	
	var maxTimelineRows: Int {
		
		return activeTimelineContentsController.maxTimelineRows
	}
	
	
	func appendTweets(tweets: [Status], associatedHashtags hashtags: HashtagSet) -> (insertedIndexes: IndexSet, ignoredIndexes: IndexSet, removedIndexes: IndexSet) {
		
		let tweetCount = tweets.count
		
		guard tweetCount != 0 else {
			
			return (insertedIndexes: IndexSet(), ignoredIndexes: IndexSet(), removedIndexes: IndexSet())
		}
		
		let currentRows = currentTimelineRows
		let maxRows = maxTimelineRows
		let insertRows = min(tweetCount, maxRows)
		let overflowRows = max(0, (insertRows + currentRows) - maxRows)
		
		let ignoreRows = max(0, tweetCount - maxRows)
		
		let getInsertRange = { Range(NSMakeRange(0, insertRows))! }
		let getIgnoreRange = { Range(NSMakeRange(maxRows - ignoreRows, ignoreRows))! }
		let getRemoveRange = { Range(NSMakeRange(currentRows - overflowRows, overflowRows))! }
		
		let insertIndexes = IndexSet(integersIn: getInsertRange())
		let ignoreIndexes = ignoreRows > 0 ? IndexSet(integersIn: getIgnoreRange()) : IndexSet()
		let removeIndexes = overflowRows > 0 ? IndexSet(integersIn: getRemoveRange()) : IndexSet()
		
		activeTimelineContentsController.appendTweets(tweets: tweets)
		
		timelineTableView.beginUpdates()
		timelineTableView.removeRows(at: removeIndexes, withAnimation: [.effectFade, .slideDown])
		timelineTableView.insertRows(at: insertIndexes, withAnimation: [.effectFade, .slideDown])
		timelineTableView.endUpdates()
		
		return (insertedIndexes: insertIndexes, ignoredIndexes: ignoreIndexes, removedIndexes: removeIndexes)
	}
	
	func getNextTimelineSelection(insertedIndexes: IndexSet) -> IndexSet {
		
		func shiftIndex(currentIndexes: IndexSet, insertIndex: Int) -> IndexSet {
			
			let currentIndexes = currentIndexes.sorted(by: <)
			
			let noEffectIndexes = currentIndexes.filter { $0 < insertIndex }
			let shiftedIndexes = currentIndexes.filter { $0 >= insertIndex } .map { $0 + 1 }
			
			return IndexSet(noEffectIndexes + shiftedIndexes)
		}
		
		func shiftIndexes(currentIndexes: IndexSet, insertIndexes: IndexSet) -> IndexSet {
			
			var insertIndexesGenerator = insertIndexes.makeIterator()
			
			if let insertIndex = insertIndexesGenerator.next() {
				
				let currentIndexes = shiftIndex(currentIndexes: currentIndexes, insertIndex: insertIndex)
				let insertIndexes = IndexSet(insertIndexes.dropFirst())
				
				return shiftIndexes(currentIndexes: currentIndexes, insertIndexes: insertIndexes)
			}
			else {
				
				return currentIndexes
			}
		}
		
		return shiftIndexes(currentIndexes: self.currentTimelineSelectedRowIndexes, insertIndexes: insertedIndexes)
	}
}
extension TimelineViewController : TimelineGetStatusesController {
	
	private func updateStatuses() {
		
		guard NSApp.twitterController.readyToUse else {
			
			return
		}
		
		func update(tweets: [Status], hashtags: HashtagSet) {
			
			DebugTime.print("Current Selection:\n\tCurrentTimelineSelectedRows: \(self.currentTimelineSelectedRowIndexes)\n\tNative: \(self.timelineTableView.selectedRowIndexes)")
			
			let result = self.appendTweets(tweets: tweets, associatedHashtags: hashtags)
			let nextSelectedIndexes = self.getNextTimelineSelection(insertedIndexes: result.insertedIndexes)
			
			NSLog("Tweet: \(tweets.count)")
			NSLog("Inserted: \(result.insertedIndexes)")
			NSLog("Ignored: \(result.ignoredIndexes)")
			NSLog("Removed: \(result.removedIndexes)")
			
			self.currentTimelineSelectedRowIndexes = nextSelectedIndexes
			
			DebugTime.print("Next Selection:\n\tCurrentTimelineSelectedRows: \(self.currentTimelineSelectedRowIndexes)\n\tNative: \(self.timelineTableView.selectedRowIndexes)")
		}
		
		displayControlState = .Updating
		
		activeTimelineContentsController.updateContents { result in
			
			self.displayControlState = .Updated
			
			switch result {
				
			case .success(let statuses, let hashtags):
				
				#warning("ここで hashtags に依存すると融通が効かない。")
				update(tweets: statuses, hashtags: hashtags)
				
				self.message.send(message: .resetAutoUpdateIntervalDeray)
				self.timelineStatusView.OKMessage = "Last Update: \(Date().displayString)"
				
			case .failure(let error):
				
				//				if error.isRateLimitExceeded {
				//
				//					self.message.send(message: .AddAutoUpdateIntervalDelay(7.0))
				//				}
				
				self.reportTimelineGetStatusError(error: error)
			}
		}
	}
}

extension TimelineViewController : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let cell = activeTimelineContentsController.tableCell(for: row)

//		cell?.selected = tableView.isRowSelected(row)
        cell?.selected = currentTimelineSelectedRowIndexes.contains(row)

		return cell?.toTimelineView()
	}

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		return activeTimelineContentsController.estimateCellHeight(of: row)
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
	
	@objc func timelineKindStateChanged(_ sender: TimelineKindStateController, kind: TimelineKind) {
		
		updateTimeline()
	}
}

extension TimelineViewController : TimelineContentsControllerDelegate {
	
	func timelineContentsNeedsUpdate(_ sender: TimelineContentsController) {
		
		//		message.send(message: .changeHashtags(hashtags))
		
		timelineTableView.insertRows(at: IndexSet(integer: 0), withAnimation: TableViewInsertAnimationOptions)
		message.send(message: .updateStatuses)
	}
}
