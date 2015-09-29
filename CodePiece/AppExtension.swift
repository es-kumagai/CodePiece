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

private let welcomeBoardWindowController = try! Storyboard.WelcomeBoard.getInitialController()
private let preferencesWindowController = try! Storyboard.PreferencesWindow.getInitialController()

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
