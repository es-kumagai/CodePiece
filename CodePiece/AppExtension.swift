//
//  Application.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

extension NSApplication {
	
	func showWelcomeBoard() {
		
		let windowController = Storyboard.WelcomeBoard.defaultController as! WelcomeBoardWindowController
		
		NSApp.runModalForWindow(windowController.window!)
	}
	
	func showPreferencesWindow() {
		
		let windowController = Storyboard.PreferencesWindow.defaultController as! PreferencesWindowController
		
		NSApp.runModalForWindow(windowController.window!)
	}
}
