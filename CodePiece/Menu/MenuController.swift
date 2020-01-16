//
//  MenuController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Ocean

final class MenuController : NSObject {

	var application:NSApplication {
		
		return NSApp
	}
	
	var mainViewController:MainViewController? {
		
		return application.baseViewController?.mainViewController
	}
	
	var timelineViewController:TimelineViewController? {
		
		return application.baseViewController?.timelineViewController
	}
	
	override init() {
		
		super.init()
	}
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
	}

	var isMainViewControllerActive:Bool {
	
		return self.mainViewController != nil
	}
	
	var canPostToSNS:Bool {
		
		return self.mainViewController?.canPost ?? false
	}
	
	@IBAction func showPreferences(sender:NSMenuItem?) {
		
		NSApp.showPreferencesWindow()
	}

	@IBAction func showWelcomeBoard(sender:NSMenuItem?) {
		
		NSApp.showWelcomeBoard()
	}
	
	@IBAction func moveFocusToCodeArea(sender:NSObject?) {
		
		self.mainViewController?.focusToCodeArea()
	}
	
	@IBAction func moveFocusToDescription(sender:NSObject?) {
		
		self.mainViewController?.focusToDescription()
	}
	
	@IBAction func moveFocusToHashtag(sender:NSObject?) {
		
		self.mainViewController?.focusToHashtag()
	}
	
	@IBAction func moveFocusToLanguage(sender:NSObject?) {
		
		self.mainViewController?.focusToLanguage()
	}
	
	@IBAction func postToSNS(sender:NSMenuItem?) {
		
		self.mainViewController?.postToSNS()
	}
	
	@IBAction func clearTweetAndDescription(sender:NSMenuItem?) {
		
		self.mainViewController?.clearDescriptionText()
	}
	
	@IBAction func clearCodeAndDescription(sender: NSMenuItem?) {
	
		self.mainViewController?.clearCodeText()
		self.mainViewController?.clearDescriptionText()
	}
	
	@IBAction func clearHashtag(sender:NSMenuItem?) {
		
		self.mainViewController?.clearHashtags()
	}
	
	@IBAction func clearCode(sender:NSMenuItem?) {
		
		self.mainViewController?.clearCodeText()
	}
	
	var hasReplyingToStatusID: Bool {
		
		return mainViewController?.hasStatusForReplyTo ?? false
	}
	
	@IBAction func clearReplyingToStatusID(sender: NSMenuItem?) {
		
		mainViewController?.clearReplyTo()
	}
	
	var canOpenBrowserWithSearchHashtagPage:Bool {
	
		return self.mainViewController?.canOpenBrowserWithSearchHashtagPage ?? false
	}
	
	@IBAction func openBrowserWithSearchHashtagPage(sender:NSMenuItem?) {
		
		self.mainViewController?.openBrowserWithSearchHashtagPage()
	}
	
	var isTimelineActive: Bool {
	
		return self.timelineViewController?.isTimelineActive ?? false
	}
	
	@IBAction func reloadTimeline(sender: NSMenuItem?) {
		
		self.timelineViewController?.reloadTimeline()
	}
	
	var canOpenBrowserWithCurrentTwitterStatus:Bool {
		
		return self.mainViewController?.canOpenBrowserWithCurrentTwitterStatus ?? false
	}
	
	@IBAction func openBrowserWithCurrentTwitterStatus(sender: AnyObject) {
		
		self.mainViewController?.openBrowserWithCurrentTwitterStatus()
	}
}
