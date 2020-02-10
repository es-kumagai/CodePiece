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

private var _isReadyForUse: Bool = false

extension NSApplication : AlertDisplayable {
	
}

extension NSApplication {
	
	var baseViewController: BaseViewController! {
	
		return keyWindow?.contentViewController as? BaseViewController
	}
	
	var mainViewController: MainViewController! {
		
		return baseViewController?.mainViewController
	}
	
	var timelineTabViewController: TimelineTabViewController! {
		
		return baseViewController?.timelineTabViewController
	}
	
	static func readyForUse() {
		
		guard !_isReadyForUse else {
		
			fatalError("Application is already ready.")
		}
		
		environment = Environment()
		settings = Settings()
		controllers = AppGlobalControllers()
		
		_isReadyForUse = true
	}
	
	var isReadyForUse: Bool {
	
		return _isReadyForUse
	}
}

// MARK: - Controllers

extension NSApplication {
	
	private static var environment: Environment!
	private static var controllers: AppGlobalControllers!
	private static var settings: Settings!
	
	var environment: Environment {
		
		return Self.environment
	}
	
	var settings: Settings {
	
		return Self.settings
	}
	
	var controllers: AppGlobalControllers {

		return Self.controllers
	}
	
	var snsController: SNSController {
		
		return controllers.sns
	}
	
	var twitterController: TwitterController {
		
		return snsController.twitter
	}
	
	var gistsController: GistsController {
		
		return snsController.gists
	}
	
	var captureController: WebCaptureController {
		
		return controllers.captureController
	}
	
	var reachabilityController: ReachabilityController {
		
		return controllers.reachabilityController
	}
}

private let welcomeBoardWindowController = try! Storyboard.WelcomeBoard.getInitialController()
private let preferencesWindowController = try! Storyboard.PreferencesWindow.getInitialController()

// MARK: - Windows

extension NSApplication {
	
	func showWelcomeBoard() {

		welcomeBoardWindowController.showWindow(self)
	}
	
	func closeWelcomeBoard() {
		
		welcomeBoardWindowController.close()
	}
	
	func showPreferencesWindow() {

		preferencesWindowController.showWindow(self)		
	}

	func closePreferencesWindow() {

		preferencesWindowController.close()
	}
}
