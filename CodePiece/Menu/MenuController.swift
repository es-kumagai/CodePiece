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
	
	override init() {
		
		super.init()
	}
	
	@IBAction func showPreferences(sender:NSMenuItem?) {
		
		let windowController = Storyboard.PreferencesWindow.defaultController as! PreferencesWindowController
		
		self.application.runModalForWindow(windowController.window!)
	}
}
