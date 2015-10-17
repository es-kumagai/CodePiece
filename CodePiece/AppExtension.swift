//
//  AppExtension.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim
import Ocean
import ESTwitter

private var isReadyForUse:Bool = false

extension NSApplication : AlertDisplayable {
	
}

extension NSApplication {
	
	static func readyForUse() {
		
		guard !CodePiece.isReadyForUse else {
		
			fatalError("Application is already ready.")
		}
		
		self.settings = Settings()
		self.controllers = AppGlobalControllers()
		
		CodePiece.isReadyForUse = true
	}
	
	var isReadyForUse:Bool {
	
		return CodePiece.isReadyForUse
	}
}

// MARK: - Controllers

extension NSApplication {
	
	private static var controllers:AppGlobalControllers!
	private static var settings:Settings!
	
	var settings:Settings {
	
		return self.dynamicType.settings
	}
	
	var controllers:AppGlobalControllers {

		return self.dynamicType.controllers
	}
	
	var snsController:SNSController {
		
		return self.controllers.sns
	}
	
	var twitterController:TwitterController {
		
		return self.snsController.twitter
	}
	
	var gistsController:GistsController {
		
		return self.snsController.gists
	}
	
	var captureController:WebCaptureController {
		
		return self.controllers.captureController
	}
	
	var reachabilityController:ReachabilityController {
		
		return self.controllers.reachabilityController
	}
}

private let welcomeBoardWindowController = try! Storyboard.WelcomeBoard.getInitialController()
private let preferencesWindowController = try! Storyboard.PreferencesWindow.getInitialController()

// MARK: - Windows

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
