//
//  ContentsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter

class TimelineContentsController : NSObject {
	
	typealias UpdateResult = Result<([Status], associatedHashtags: HashtagSet), GetStatusesError>
	
	var notificationHandlers = Notification.Handlers()

	@IBOutlet var tableView: TimelineTableView? {
		
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
	func updateContents(callback: @escaping (UpdateResult) -> Void) {}
	
	func deactivate() {
		
		notificationHandlers.releaseAll()
	}
	
	deinit {
		
		deactivate()
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
