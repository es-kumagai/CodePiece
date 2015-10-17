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

// FIXME: Settings を NSApp の静的プロパティとして実装したい
var settings:Settings!

extension NSApplication : AlertDisplayable {
	
}

// MARK: - Controllers

extension NSApplication {
	
	static let controllers = AppGlobalControllers()
	
	var controllers:AppGlobalControllers {

		return self.dynamicType.controllers
	}
	
	var snsController:SNSController! {
		
		return self.controllers.sns
	}
	
	var twitterController:TwitterController! {
		
		return self.snsController?.twitter
	}
	
	var gistsController:GistsController! {
		
		return self.snsController?.gists
	}
	
	var captureController:WebCaptureController! {
		
		return self.controllers.captureController
	}
	
	var reachabilityController:ReachabilityController! {
		
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
