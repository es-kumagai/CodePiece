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

extension Sequence where Element : TimelineViewController {

	func activate() {
		
		forEach { $0.activate() }
	}
	
	func deactivate() {
		
		forEach { $0.deactivate() }
	}
}

@objcMembers
final class TimelineViewController: NSViewController {
	
	struct SelectingStatusInfo {
	
		var row: Int
		var status: Status
	}
	
	@IBOutlet var menuController: MenuController!
	
	@IBOutlet var timelineTableView: TimelineTableView! {
		
		didSet {
			
			contentsController.tableView = timelineTableView
			refreshDisplayState()
		}
	}
	
	var contentsController: TimelineContentsController! {
		
		didSet {
			
			contentsController.owner = self
			contentsController.delegate = self
		}
	}
	
	var notificationHandlers = Notification.Handlers()
	
	@IBOutlet var cellForEstimateHeight: TimelineTableCellView!
	
	var isActive: Bool = false
	var contentsState: TimelineStatusView.State = .ok("") {
		
		didSet {
			
			guard isViewLoaded else {
				
				return
			}
			
			refreshDisplayState()
		}
	}
	
	// Manage current selection by this property because selection indexes is reset when call insertRowsAtIndexes method for insert second cell.
	var timelineSelectedStatuses: [SelectingStatusInfo] = [] {
		
		willSet {

			willChangeValue(forKey: "canReplyRequest")
			willChangeValue(forKey: "canOpenBrowserWithCurrentTwitterStatus")
		}
		
		didSet {
			
			defer {

				didChangeValue(forKey: "canReplyRequest")
				didChangeValue(forKey: "canOpenBrowserWithCurrentTwitterStatus")
			}
			
			guard isViewLoaded else {
				
				return
			}
			
			for cell in timelineTableView.makedCells {
				
				cell.applySelection()
			}
			
			TimelineSelectionChangedNotification(timelineViewController: self, selectedCells: timelineTableView.selectedCells).post()
		}
	}
	
	var isTimelineSingleRowSelected: Bool {
		
		return timelineSelectedStatuses.count == 1
	}
	
	var isTimelineSingleOrMoreRowsSelected: Bool {
		
		return timelineSelectedStatuses.count > 0
	}
	
	enum Message : MessageTypeIgnoreInQuickSuccession {
		
		case setAutoUpdateInterval(Double)
		case addAutoUpdateIntervalDelay(bySecond: Double)
		case resetAutoUpdateIntervalDeray
		case setReachability(ReachabilityController.State)
		case autoUpdate(enable: Bool)
		case updateStatuses
		
		func blockInQuickSuccession(lastMessage: Message) -> Bool {
			
			switch (self, lastMessage) {
				
			case (.updateStatuses, .updateStatuses):
				return true
				
			default:
				return false
			}
		}
	}
	
	@IBOutlet var timelineStatusView: TimelineStatusView! {
		
		didSet {
			
			timelineStatusView.clearMessage()
			refreshDisplayState()
		}
	}
	
	@IBOutlet var timelineUpdateIndicator: NSProgressIndicator? {
		
		didSet {
			
			timelineUpdateIndicator?.usesThreadedAnimation = true
		}
	}
	
	@IBOutlet var timelineRefreshButton: NSButton?
	
	var statusesAutoUpdateInterval: Double = 20 {
		
		didSet {

			guard isActive else {
				
				return
			}
			
			message.send(.setAutoUpdateInterval(statusesAutoUpdateInterval))
		}
	}
	
	private(set) var displayControlState = DisplayControlState.updated {
		
		didSet {
			
			precondition(Thread.isMainThread)
			
			self.updateDisplayControlsVisiblityForState()
		}
	}
	
	private var autoUpdateState = AutoUpdateState()
	
	private(set) lazy var message: MessageQueue<Message> = {
		
		DebugTime.print("Message Queue for Timeline of \(contentsKind) will be Initialize.")
		
		let queue = MessageQueue<Message>(identifier: "CodePiece.Timeline.\(contentsKind)", handler: self)

		updateTimerSource = queue.makeTimerSource(interval: Semaphore.Interval(second: 0.03), start: true, timerAction: autoUpdateAction)
		
		return queue
	}()
	
	private var updateTimerSource: DispatchSourceTimer!
	
	var isTimelineActive: Bool {
		
		return true
	}
	
	@IBAction func pushTimelineRefreshButton(_ sender: AnyObject!) {
		
		updateTimeline()
	}
}

extension TimelineViewController {
	
	var contentsKind: TimelineKind {
	
		return contentsController.kind
	}
	
	func refreshDisplayState() {
		
		timelineStatusView.state = contentsState
		contentsController.updateContents()
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
			message.send(.updateStatuses)
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
			_changeAutoUpdateIntervalDelay(bySecond: interval)
			
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
		
		DispatchQueue.main.async {
			
			self.updateStatuses()
		}
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
		
		DebugTime.print("Timeline auto update interval of \(contentsKind): \(interval)")
		autoUpdateState.updateInterval = Semaphore.Interval(second: interval)
	}
	
	private func _changeAutoUpdateIntervalDelay(bySecond interval: Double) {
		
		autoUpdateState.addUpdateIntervalDelay(bySecond: interval)
		
		NSLog("Next timeline update will delay %@ seconds.", autoUpdateState.updateIntervalDelay.description)
	}
	
	private func _resetAutoUpdateIntervalDelay() {
		
		guard autoUpdateState.updateIntervalDelay != .zero else {
			
			return
		}
		
		autoUpdateState.resetUpdateIntervalDelay()
		NSLog("Delay for timeline update turns to neutral.")
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
	
	func activate() {
		
		guard !isActive else {
			
			return
		}

		DebugTime.print("Timeline of \(contentsKind) is now active.")

		isActive = true
		
		contentsController.activate()
		
		message.send(.setAutoUpdateInterval(statusesAutoUpdateInterval))
		message.send(.setReachability(NSApp.reachabilityController.state))
		message.send(.autoUpdate(enable: true))

		message.send(.start)
	}
	
	func deactivate() {
		
		guard isActive else {
			
			return
		}

		DebugTime.print("Timeline of \(contentsKind) is now deactive.")

		isActive = false
		
		message.send(.autoUpdate(enable: false))
		message.send(.stop)
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()

		observe(TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.message.send(.updateStatuses)
		}
		
		observe(notificationNamed: NSWorkspace.willSleepNotification) { [unowned self] notification in
			
			self.message.send(.autoUpdate(enable: false))
		}
		
		observe(notificationNamed: NSWorkspace.didWakeNotification) { [unowned self] notification in
			
			self.message.send(.autoUpdate(enable: true))
		}
		
		observe(ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] notification in
			
			self.message.send(.setReachability(notification.state))
		}

		contentsController.timelineViewDidLoad(isTableViewAssigned: timelineTableView != nil)
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		contentsController.timelineViewWillAppear(isTableViewAssigned: timelineTableView != nil)

		updateDisplayControlsVisiblityForState()

		// When each time the view will appear, synchronous the current selection again.
//		currentTimelineSelectedRowIndexes = timelineTableView.selectedRowIndexes
	}
	
	override func viewDidAppear() {
		
		super.viewDidAppear()
		contentsController.timelineViewDidAppear()

		refreshDisplayState()
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		contentsController.timelineViewWillDisappear()
	}
	
	override func viewDidDisappear() {
		
		super.viewDidDisappear()
		contentsController.timelineViewDidDisappear()
	}
	
	func updateTimeline() {
		
		message.send(.updateStatuses)
	}
}

// MARK: - Tweets control

// FIXME: TimelineTableControllerType で実装していたもの。動作できたら正式にここに残します。
extension TimelineViewController {
	
	var currentTimelineRows: Int {
		
		guard isViewLoaded else {

			return 0
		}
		
		return timelineTableView.numberOfRows
	}
	
	var maxTimelineRows: Int {
		
		return contentsController.maxTimelineRows
	}
	
	@discardableResult
	func appendTweets(tweets: [Status], associatedHashtags hashtags: HashtagSet) -> (insertedIndexes: IndexSet, ignoredIndexes: IndexSet, removedIndexes: IndexSet) {
		
		let tweetCount = tweets.count
		
		guard tweetCount != 0 else {
			
			return (insertedIndexes: IndexSet(), ignoredIndexes: IndexSet(), removedIndexes: IndexSet())
		}
		
		contentsController.appendTweets(tweets: tweets)
		
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
		
		if isViewLoaded {
			
			timelineTableView.beginUpdates()
			timelineTableView.removeRows(at: removeIndexes, withAnimation: [.effectFade, .slideDown])
			timelineTableView.insertRows(at: insertIndexes, withAnimation: [.effectFade, .slideDown])
			timelineTableView.endUpdates()
		}
		
		return (insertedIndexes: insertIndexes, ignoredIndexes: ignoreIndexes, removedIndexes: removeIndexes)
	}
	
	func getNextTimelineSelection(insertedIndexes: IndexSet) -> [SelectingStatusInfo] {

		func shiftIndex(currentSelections: [SelectingStatusInfo], insertIndex: Int) -> [SelectingStatusInfo] {

			let currentSelections = currentSelections.sorted { $0.row < $1.row }

			let noEffectSelections = currentSelections.filter { $0.row < insertIndex }
			let shiftedSelections = currentSelections.filter { $0.row >= insertIndex } .map { SelectingStatusInfo(row: $0.row + 1, status: $0.status) }

			return noEffectSelections + shiftedSelections
		}

		func shiftIndexes(currentSelections: [SelectingStatusInfo], insertIndexes: IndexSet) -> [SelectingStatusInfo] {

			var insertIndexesGenerator = insertIndexes.makeIterator()

			if let insertIndex = insertIndexesGenerator.next() {

				let currentSelections = shiftIndex(currentSelections: currentSelections, insertIndex: insertIndex)
				let insertIndexes = IndexSet(insertIndexes.dropFirst())

				return shiftIndexes(currentSelections: currentSelections, insertIndexes: insertIndexes)
			}
			else {

				return currentSelections
			}
		}

		return shiftIndexes(currentSelections: timelineSelectedStatuses, insertIndexes: insertedIndexes)
	}
}

extension TimelineViewController {
	
	private func updateStatuses() {
		
		guard NSApp.twitterController.readyToUse else {
			
			return
		}
		
		guard displayControlState != .updating else {
			
			NSLog("%@", "Skip update \(contentsKind) contents because other updating process still running.")
			return
		}
		
		func update(tweets: [Status], associatedHashtags hashtags: HashtagSet) {
			
			func _debugTimeReportTableState() {

				#if DEBUG
				guard let timelineTableView = timelineTableView else {
				
					NSLog("%@", "Table view for '\(contentsKind)' is still inactive.")
					return
				}
				
				DebugTime.print("""
				Current Selection:
					CurrentTimelineSelectedRows: \(timelineSelectedStatuses.map { $0.row })
					Native: \(timelineTableView.selectedRowIndexes)")
				""")
				#endif
			}
			
			_debugTimeReportTableState()

			let result = appendTweets(tweets: tweets, associatedHashtags: hashtags)
			let nextSelectedStatuses = self.getNextTimelineSelection(insertedIndexes: result.insertedIndexes)

			// FIXME: 複雑なデバッグ表示は DebugTime にメソッドとして載せて１業で表現しても良いかもしれない。
			DebugTime.print("Tweet: \(tweets.count)")
			DebugTime.print("Inserted: \(result.insertedIndexes)")
			DebugTime.print("Ignored: \(result.ignoredIndexes)")
			DebugTime.print("Removed: \(result.removedIndexes)")

			timelineSelectedStatuses = nextSelectedStatuses
			
			_debugTimeReportTableState()
		}
		
		displayControlState = .updating
		
		DebugTime.print("Start updating contents of \(contentsKind).")
		
		contentsController.updateContents { result in
			
			self.displayControlState = .updated
			
			switch result {
				
			case .success(let (statuses, hashtags)):
				
				update(tweets: statuses, associatedHashtags: hashtags)
				
				self.message.send(.resetAutoUpdateIntervalDeray)
				self.contentsState = .ok("Last Update: \(Date().displayString)")
				
			case .failure(let error):
				
				if error.isRateLimitExceeded {

					self.message.send(message: .addAutoUpdateIntervalDelay(bySecond: 7.0))
				}
				
				self.contentsState = .error(error)
			}
		}
	}
}

extension TimelineViewController : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let cell = contentsController.tableCell(for: row)

//		cell?.selected = tableView.isRowSelected(row)
		cell?.selected = timelineSelectedStatuses.contains(row: row)

		return cell?.toTimelineView()
	}

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		return contentsController.estimateCellHeight(of: row)
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
		
		timelineSelectedStatuses = tableView.selectedCells.compactMap {
			
			guard let status = $0.cell?.item?.status else {
				
				return nil
			}

			return SelectingStatusInfo(row: $0.row, status: status)
		}
	}
}

extension TimelineViewController : TimelineContentsControllerDelegate {
	
	func timelineContentsNeedsUpdate(_ sender: TimelineContentsController) {
		
		if isViewLoaded, contentsController.items.count > 0 {
			
			timelineTableView.insertRows(at: IndexSet(integer: 0), withAnimation: TableViewInsertAnimationOptions)
		}
		
		message.send(.updateStatuses)
	}
}

extension Sequence where Element == TimelineViewController.SelectingStatusInfo {
	
	func contains(row: Int) -> Bool {
		
		return map { $0.row }.contains(row)
	}
}
