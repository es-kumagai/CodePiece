//
//  MenuController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Ocean

@objcMembers
final class MenuController : NSObject {

	var application: NSApplication {
		
		return NSApp
	}
	
	var mainViewController: MainViewController? {
		
		return application.baseViewController?.mainViewController
	}
	
	var timelineViewController: TimelineViewController? {
		
		return application.baseViewController?.timelineViewController
	}
	
	override init() {
		
		super.init()
	}
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
	}

	var isMainViewControllerActive: Bool {
	
		return mainViewController != nil
	}
	
	var canPostToSNS: Bool {
		
		return mainViewController?.canPost ?? false
	}
	
	@IBAction func showPreferences(_ sender: NSMenuItem?) {
		
		NSApp.showPreferencesWindow()
	}

	@IBAction func showWelcomeBoard(_ sender: NSMenuItem?) {
		
		NSApp.showWelcomeBoard()
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
		
		mainViewController?.postToSNS()
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
		
		mainViewController?.clearReplyTo()
	}
	
	var canOpenBrowserWithSearchHashtagPage:Bool {
	
		return mainViewController?.canOpenBrowserWithSearchHashtagPage ?? false
	}
	
	@IBAction func openBrowserWithSearchHashtagPage(_ sender: NSMenuItem?) {
		
		self.mainViewController?.openBrowserWithSearchHashtagPage()
	}
	
	var isTimelineActive: Bool {
	
		return timelineViewController?.isTimelineActive ?? false
	}
	
	@IBAction func reloadTimeline(_ sender: NSMenuItem?) {
		
		timelineViewController?.updateTimeline()
	}
	
	var canOpenBrowserWithCurrentTwitterStatus:Bool {
		
		return mainViewController?.canOpenBrowserWithCurrentTwitterStatus ?? false
	}
	
	@IBAction func openBrowserWithCurrentTwitterStatus(_ sender: AnyObject) {
		
		mainViewController?.openBrowserWithCurrentTwitterStatus()
	}
}
