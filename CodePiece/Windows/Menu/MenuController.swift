//
//  MenuController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Ocean

@MainActor
@objcMembers
final class MenuController : NSObject {

	@IBOutlet var timelineHashtagsMenuItem: NSMenuItem!
	@IBOutlet var timelineMyTweetsMenuItem: NSMenuItem!
	@IBOutlet var timelineMentionsMenuItem: NSMenuItem!
	@IBOutlet var timelineRelatedTweetsMenuItem: NSMenuItem!

	var timelineMenuItemsOrderedByTimelineIndex: [NSMenuItem] {

		return [
			timelineHashtagsMenuItem,
			timelineMyTweetsMenuItem,
			timelineMentionsMenuItem,
			timelineRelatedTweetsMenuItem
		]
	}
	
	var application: CodePieceApplication {
		
		NSApp
	}
	
	var mainViewController: MainViewController? {
		
		application.baseViewController?.mainViewController
	}
	
	var timelineTabViewController: TimelineTabViewController? {
		
		application.baseViewController?.timelineTabViewController
	}
	
	var currentTimelineViewController: TimelineViewController? {
		
		application.timelineTabViewController?.currentTimelineViewController
	}
	
	override init() {
		
		super.init()
	}
	
	var isMainViewControllerActive: Bool {
	
		mainViewController != nil
	}
	
	dynamic var canPostToSNS: Bool {
		
		mainViewController?.canPost ?? false
//		Task.blocking { [unowned self] in
//
//			await mainViewController?.canPost ?? false
//		}
	}
	
	@IBAction func showPreferences(_ sender: NSMenuItem?) {
		
		application.showPreferencesWindow()
	}

	@IBAction func showWelcomeBoard(_ sender: NSMenuItem?) {
		
		application.showWelcomeBoard()
	}
	
	@IBAction func moveFocusToCodeArea(_ sender: NSObject?) {
		
		mainViewController?.focusToCodeArea()
	}
	
	@IBAction func moveFocusToDescription(_ sender: NSObject?) {
		
		mainViewController?.focusToDescription()
	}
	
	@IBAction func moveFocusToHashtag(_ sender: NSObject?) {
		
		mainViewController?.focusToHashtag()
	}
	
	@IBAction func moveFocusToLanguage(_ sender: NSObject?) {
		
		mainViewController?.focusToLanguage()
	}
	
	@IBAction func postToSNS(_ sender: NSMenuItem?) {
		
		Task {
			await mainViewController?.postToSNS()
		}
	}
	
	@IBAction func clearTweetAndDescription(_ sender: NSMenuItem?) {
		
		mainViewController?.clearDescriptionText()
	}
	
	@IBAction func clearCodeAndDescription(_ sender: NSMenuItem?) {
	
		mainViewController?.clearCodeText()
		mainViewController?.clearDescriptionText()
	}
	
	@IBAction func clearHashtag(_ sender: NSMenuItem?) {
		
		mainViewController?.clearHashtags()
	}
	
	@IBAction func clearCode(_ sender: NSMenuItem?) {

		mainViewController?.clearCodeText()
	}
	
	var hasReplyingToStatusID: Bool {
		
		return mainViewController?.hasStatusForReplyTo ?? false
	}
	
	@IBAction func clearReplyingToStatusID(_ sender: NSMenuItem?) {
		
		mainViewController?.clearReplyingStatus()
	}
	
	var canOpenBrowserWithSearchHashtagPage: Bool {
	
		return mainViewController?.canOpenBrowserWithRelatedTweets ?? false
	}
	
	var canOpenBrowserWithCurrentTwitterStatus: Bool {
		
		application.canOpenBrowserWithCurrentTwitterStatus
	}
	
	var canOpenBrowserWithRelatedTweets: Bool {
		
		mainViewController?.canOpenBrowserWithRelatedTweets ?? false
	}
	
	var isTimelineActive: Bool {
	
		currentTimelineViewController?.isTimelineActive ?? false
	}
	
	@IBAction func reloadTimeline(_ sender: NSMenuItem?) {
		
		currentTimelineViewController?.updateTimeline()
	}
	
	@IBAction func openBrowserWithSearchHashtagPage(_ sender: NSMenuItem?) {
		
		mainViewController?.openBrowserWithSearchHashtagPage()
	}
	
	@IBAction func openBrowserWithCurrentTwitterStatus(_ sender: AnyObject) {
		
		application.openBrowserWithCurrentTwitterStatus()
	}

	@IBAction func openBrowserWithRelatedStatuses(_ sender: AnyObject) {
		
		mainViewController?.openBrowserWithRelatedTweets()
	}
	
	@IBAction func selectTimeline(_ sender: Any) {
		
		guard let menuItem = sender as? NSMenuItem else {
			
			return
		}
		
		guard let target = timelineMenuItemsOrderedByTimelineIndex.enumerated()
			.first(where: { $0.element === menuItem }) else {
				
				NSLog("%@", "Unknown timeline is selected. (\(type(of: menuItem))")
				return
		}

		timelineTabViewController?.currentTimelineKind = TimelineKind(rawValue: target.offset)
	}
	
	@IBAction func openSearchTweetsWindow(_ sender: Any) {
		
		mainViewController?.openSearchTweetsWindow()
	}
}

extension MenuController {
	
	var canReplyTo: Bool {
		
		application.currentSelectedStatuses.count == 1
	}
	
	@IBAction func replyTo(_ sender: NSMenuItem) {
		
		TimelineReplyToSelectionRequestNotification().post()
	}
	
	var canMakeThread: Bool {
		
		mainViewController?.canMakeThread ?? false
	}
	
	@IBAction func makeThread(_ sender: NSMenuItem) {
		
		mainViewController?.setMakeThread(sender)
	}
}
