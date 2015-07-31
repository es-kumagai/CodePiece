//
//  MenuController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

final class MenuController : NSObject {

	@IBOutlet weak var application:NSApplication!

	var keyWindow:NSWindow? {
		
		return self.application.keyWindow
	}
	
	var mainViewController:ViewController? {
		
		return self.keyWindow?.contentViewController as? ViewController
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
		
		let windowController = Storyboard.PreferencesWindow.defaultController as! PreferencesWindowController
		
		self.application.runModalForWindow(windowController.window!)
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
	
	@IBAction func postToSNS(sender:NSMenuItem?) {
		
		self.mainViewController?.postToSNS()
	}
	
	@IBAction func showAboutWindow(sender:NSMenuItem?) {
		
		self.aboutWindowController.showWindow()
	}
}
