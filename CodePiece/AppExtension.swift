//
//  AppExtension.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean

var settings:Settings!

extension NSApplication : AlertDisplayable {
	
}

private let welcomeBoardWindowController = Storyboard.WelcomeBoard.defaultController as! WelcomeBoardWindowController
private let preferencesWindowController = Storyboard.PreferencesWindow.defaultController as! PreferencesWindowController

extension NSApplication {
	
	func showWelcomeBoard() {

		NSApp.runModalForWindow(welcomeBoardWindowController.window!)
	}
	
	func closeWelcomeBoard() {
		
		welcomeBoardWindowController.close()
	}
	
	func showPreferencesWindow() {
		
		preferencesWindowController.showWindow(self)
	}
}
