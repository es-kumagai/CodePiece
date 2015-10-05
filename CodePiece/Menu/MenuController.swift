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

	@IBOutlet weak var application:NSApplication!

	var keyWindow:NSWindow? {
		
		return self.application.keyWindow
	}
	
	var baseViewController:BaseViewController? {
		
		return self.keyWindow?.contentViewController as? BaseViewController
	}
	
	var mainViewController:ViewController? {
		
		return self.baseViewController?.mainViewController
	}
	
	var timelineViewController:TimelineViewController? {
		
		return self.baseViewController?.timelineViewController
	}
	
	var aboutWindowController:AboutWindowController!
	
	override init() {
		
		super.init()
	}
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
		
		self.aboutWindowController = AboutWindowController.instantiate()
		self.aboutWindowController.acknowledgementsName = "Pods-CodePiece-acknowledgements"
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
	
	@IBAction func showAboutWindow(sender:NSMenuItem?) {
		
		self.aboutWindowController.showWindow()
	}
	
	@IBAction func clearTweetAndDescription(sender:NSMenuItem?) {
		
		self.mainViewController?.clearDescriptionText()
	}
	
	@IBAction func clearHashtag(sender:NSMenuItem?) {
		
		self.mainViewController?.clearHashtag()
	}
	
	@IBAction func clearCode(sender:NSMenuItem?) {
		
		self.mainViewController?.clearCodeText()
	}
	
	var canOpenBrowserWithSearchHashtagPage:Bool {
	
		return self.mainViewController?.canOpenBrowserWithSearchHashtagPage ?? false
	}
	
	@IBAction func openBrowserWithSearchHashtagPage(sender:NSMenuItem?) {
		
		self.mainViewController?.openBrowserWithSearchHashtagPage()
	}
}
