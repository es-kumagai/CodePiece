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
	
	typealias UpdateResult = Result<(statuses: [Status], hashtags: HashtagSet), PostError>
	
	var notificationHandlers = Notification.Handlers()

	@IBOutlet var tableView: TimelineTableView?
	
	@IBOutlet weak var delegate: TimelineContentsControllerDelegate?

	func activate() {}
	func updateContents(callback: @escaping (UpdateResult) -> Void) {}
	
	func deactivate() {
		
		notificationHandlers.releaseAll()
	}
	
	deinit {
		
		deactivate()
	}

	// MARK: - Customizable

	var maxTimelineRows : Int {
	
		return 200
	}
	
	// MARK: - Neeeds Override
	
	var canReplyRequest: Bool {

		return false
	}
	
	var canOpenBrowserWithCurrentTwitterStatus: Bool {
		
		return false
	}
	
	func updateContents() {
		
		fatalError("Not implemented yet.")
	}

	func estimateCellHeight(of row: Int) -> CGFloat {

		fatalError("Not implemented yet.")
	}
	
	func tableCell(for row: Int) -> TimelineTableCellType? {
		
		fatalError("Not implemented yet.")
	}
	
	func appendTweets(tweets: [Status]) {
		
		fatalError("Not implemented yet.")
	}
}

@objc protocol TimelineContentsControllerDelegate : class {

	@objc optional func timelineContents(_ sender: TimelineContentsController, changed: Bool)
}
