//
//  ContentsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter
import Ocean

@MainActor
class TimelineContentsController : NSObject, NotificationObservable {
	
	let notificationHandlers = Notification.Handlers()

	@IBOutlet var tableView: TimelineTableView? {
		
		@MainActor
		didSet {
			
			tableView?.dataSource = tableViewDataSource
		}
	}
	
	@IBOutlet weak var delegate: TimelineContentsControllerDelegate?
	
	weak var owner: TimelineViewController?
	
	var items = Array<TimelineTableItem>()

	override required init() {
	
		super.init()
	}
	
	func activate() {}
	
	func updateContents() async throws -> UpdateResult {
		
		throw GetStatusesError.unexpectedWithDescription("Not implemented.")
	}
	
	func deactivate() {
		
		notificationHandlers.releaseAll()
	}
	
	deinit {

		Task { @MainActor in

			deactivate()
		}
	}

//	var canReplyRequest: Bool {
//
//		guard let tableView = tableView else {
//
//			return false
//		}
//
//		let indexes = tableViewDataSource.items.indexes { $0 is TimelineTweetItem }
//		let result = Set(tableView.selectedRowIndexes).isSubset(of: indexes)
//
//		return result
//	}
	
//	var canOpenBrowserWithCurrentTwitterStatus: Bool {
//
//		guard let tableView = tableView else {
//
//			return false
//		}
//
//		let indexes = tableViewDataSource.items.indexes { $0 is TimelineTweetItem }
//		let result = Set(tableView.selectedRowIndexes).isSubset(of: indexes)
//
//		return result
//	}
	
	func updateContents() {
		
		guard let tableView = tableView else {

			return
		}
		
		tableView.reloadData()
	}

	func tableCell(for row: Int) -> TimelineTableCellType? {
		
		guard let tableView = tableView else {
			
			return nil
		}
		
		let items = tableViewDataSource.items
		
		guard row < items.count else {
			
			return nil
		}
		
		let item = items[row]
		let cell = item.timelineCellType.makeCellWithItem(item: item, tableView: tableView, owner: self) as! TimelineTableCellType
		
		return cell
	}

	// MARK: - Customizable

	var maxTimelineRows : Int {
	
		return 200
	}
	
	var associatedHashtags: HashtagSet {
		
		return []
	}
	
	
	func timelineViewDidLoad(isTableViewAssigned: Bool) {}
	func timelineViewWillAppear(isTableViewAssigned: Bool) {}
	func timelineViewDidAppear() {}
	func timelineViewWillDisappear() {}
	func timelineViewDidDisappear() {}

	// MARK: - Neeeds Override
	
	var kind: TimelineKind {
	
		fatalError("Not implemented yet.")
	}
	
	var tableViewDataSource: TimelineTableDataSource {
		
		fatalError("Not implemented yet.")
	}

	func estimateCellHeight(of row: Int) -> CGFloat {

		fatalError("Not implemented yet.")
	}
	
	func appendTweets(tweets: [Status]) {
		
		fatalError("Not implemented yet.")
	}
}

extension TimelineContentsController {
	
	struct UpdateResult : Sendable {
		
		var statuses: Statuses
		var associatedHashtags: HashtagSet
		
		init(_ statuses: Statuses, associatedHashtags hashtags: HashtagSet = []) {
			
			self.statuses = statuses
			self.associatedHashtags = hashtags
		}
	}
}

extension TimelineContentsController.UpdateResult {
	
	static var nothing = Self([])
}
