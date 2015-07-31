//
//  AppExtension.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean


extension NSApplication : AlertDisplayable {
	
}

private let welcomeBoardWindowController = Storyboard.WelcomeBoard.defaultController as! WelcomeBoardWindowController

extension NSApplication {
	
	func showWelcomeBoard() {

		welcomeBoardWindowController.showWindow(self)
	}
	
	func closeWelcomeBoard() {
		
		welcomeBoardWindowController.close()
	}
	
	func showPreferencesWindow() {
		
		let preferencesWindowController = Storyboard.PreferencesWindow.defaultController as! PreferencesWindowController

		let code = NSApp.runModalForWindow(preferencesWindowController.window!)
		
		switch PreferencesWindowModalResult(rawValue: code)! {
			
		case .Close:
			sns.twitter.verifyCredentialsIfNeed { result in
				
				if let error = result.error {
					
					self.showErrorAlert("Failed to verify credentials", message: String(error))
				}
			}
		}
	}
}
