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

	var isMainViewControllerActive: Bool {
	
		return self.mainViewController != nil
	}
	
	var canPostToSNS:Bool {
		
		return self.mainViewController?.canPost ?? false
	}
	
	@IBAction func showPreferences(_ sender:NSMenuItem?) {
		
		NSApp.showPreferencesWindow()
	}

	@IBAction func showWelcomeBoard(_ sender:NSMenuItem?) {
		
		NSApp.showWelcomeBoard()
	}
	
	@IBAction func moveFocusToCodeArea(_ sender:NSObject?) {
		
		self.mainViewController?.focusToCodeArea()
	}
	
	@IBAction func moveFocusToDescription(_ sender:NSObject?) {
		
		self.mainViewController?.focusToDescription()
	}
	
	@IBAction func moveFocusToHashtag(_ sender:NSObject?) {
		
		self.mainViewController?.focusToHashtag()
	}
	
	@IBAction func moveFocusToLanguage(_ sender:NSObject?) {
		
		self.mainViewController?.focusToLanguage()
	}
	
	@IBAction func postToSNS(_ sender:NSMenuItem?) {
		
		self.mainViewController?.postToSNS()
	}
	
	@IBAction func clearTweetAndDescription(_ sender:NSMenuItem?) {
		
		self.mainViewController?.clearDescriptionText()
	}
	
	@IBAction func clearCodeAndDescription(_ sender: NSMenuItem?) {
	
		self.mainViewController?.clearCodeText()
		self.mainViewController?.clearDescriptionText()
	}
	
	@IBAction func clearHashtag(_ sender:NSMenuItem?) {
		
		self.mainViewController?.clearHashtags()
	}
	
	@IBAction func clearCode(_ sender:NSMenuItem?) {
		
		self.mainViewController?.clearCodeText()
	}
	
	var hasReplyingToStatusID: Bool {
		
		return mainViewController?.hasStatusForReplyTo ?? false
	}
	
	@IBAction func clearReplyingToStatusID(_ sender: NSMenuItem?) {
		
		mainViewController?.clearReplyTo()
	}
	
	var canOpenBrowserWithSearchHashtagPage:Bool {
	
		return self.mainViewController?.canOpenBrowserWithSearchHashtagPage ?? false
	}
	
	@IBAction func openBrowserWithSearchHashtagPage(_ sender:NSMenuItem?) {
		
		self.mainViewController?.openBrowserWithSearchHashtagPage()
	}
	
	var isTimelineActive: Bool {
	
		return self.timelineViewController?.isTimelineActive ?? false
	}
	
	@IBAction func reloadTimeline(_ sender: NSMenuItem?) {
		
		self.timelineViewController?.reloadTimeline()
	}
	
	var canOpenBrowserWithCurrentTwitterStatus:Bool {
		
		return self.mainViewController?.canOpenBrowserWithCurrentTwitterStatus ?? false
	}
	
	@IBAction func openBrowserWithCurrentTwitterStatus(_ sender: AnyObject) {
		
		self.mainViewController?.openBrowserWithCurrentTwitterStatus()
	}
}
