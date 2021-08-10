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
	
	var currentSelectedStatuses: [Status] {
		
		switch keyWindow?.contentViewController {
		
		case let viewController as BaseViewController:
			return viewController.timelineTabViewController!.currentSelectedStatuses
			
		case let viewController as SearchTweetsViewController:
			return viewController.currentSelectedStatuses
			
		default:
			return []
		}
	}
	
	var currentSelectedCells: [TimelineViewController.SelectingStatusInfo] {
		
		switch keyWindow?.contentViewController {
		
		case let viewController as BaseViewController:
			return viewController.timelineTabViewController!.currentSelectedCells
			
		case let viewController as SearchTweetsViewController:
			return viewController.currentSelectedCells
			
		default:
			return []
		}
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
	
	func moveToFront() {
		
		mainWindow?.makeKeyAndOrderFront(self)
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

private let welcomeBoardWindowController = try! Storyboard.welcomeBoard.instantiateController()
private let preferencesWindowController = try! Storyboard.preferencesWindow.instantiateController()

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
	
	var canOpenBrowserWithCurrentTwitterStatus: Bool {
	
		NSApp.currentSelectedStatuses.count == 1
	}
	
	func openBrowserWithCurrentTwitterStatus() {
		
		guard canOpenBrowserWithCurrentTwitterStatus else {
			
			let message = "UNEXPECTED ERROR: Try to open selection with browser, but not ready to open browser. (selection: \(NSApp.currentSelectedCells.map { $0.row })"
			
			NSLog("%@", message)
//			assertionFailure(message)
			
			return
		}
		
		let selectedStatuses = NSApp.currentSelectedStatuses

		guard selectedStatuses.count > 0 else {
			
			let message = "UNEXPECTED ERROR: Try to open selection with browser, but don't ready to open current status. (selection: \(NSApp.currentSelectedStatuses)"
			
			NSLog("%@", message)
//			assertionFailure(message)
			
			return
		}
		
		let status = selectedStatuses.first!
		
		do {
			
			try ESTwitter.Browser.openWithStatus(status: status)
		}
		catch let ESTwitter.Browser.BrowseError.OperationFailure(reason: reason) {
			
			showErrorAlert(withTitle: "Failed to open browser", message: reason)
		}
		catch {
			
			showErrorAlert(withTitle: "Failed to open browser", message: "Unknown error : \(error)")
		}
	}
}
