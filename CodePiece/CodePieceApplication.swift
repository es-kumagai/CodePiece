//
//  CodePieceApplication.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/12/20.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import ESTwitter
import Ocean
import Sky

@MainActor
@objc(ESCodePieceApplication)
final class CodePieceApplication : NSApplication {

	private(set) var isPrepared = false

	private(set) var environment: Environment!
	private(set) var controllers: AppGlobalControllers!
	private(set) var settings: Settings!

	private(set) var welcomeBoardWindowController: WelcomeBoardWindowController!
	private(set) var preferencesWindowController: PreferencesWindowController!
	
	func prepare() {
		
		guard !isPrepared else {
		
			fatalError("Application is already ready.")
		}
		
		isPrepared = true
		
		environment = Environment()
		settings = Settings()
		controllers = AppGlobalControllers()

		welcomeBoardWindowController = try! Storyboard.welcomeBoard.instantiateController()
		preferencesWindowController = try! Storyboard.preferencesWindow.instantiateController()
	}
}

extension NSApplication : AlertDisplayable {
	
}

// MARK: - Controllers

extension CodePieceApplication {
	
	var baseViewController: BaseViewController! {
	
		keyWindow?.contentViewController as? BaseViewController
	}
	
	var mainViewController: MainViewController! {
		
		baseViewController?.mainViewController
	}
	
	var timelineTabViewController: TimelineTabViewController! {
		
		baseViewController?.timelineTabViewController
	}
	
	var snsController: SNSController {
		
		controllers.sns
	}

	var twitterController: TwitterController {
		
		snsController.twitter
	}

	var gistsController: GistsController {
		
		snsController.gists
	}

	var captureController: WebCaptureController {
		
		controllers.captureController
	}

	var reachabilityController: ReachabilityController {
		
		controllers.reachabilityController
	}
}

// MARK: - Windows

extension NSApplication : HavingScale {
	
	public var scale: CGScale {
		
		keyWindow?.scale ?? .actual
	}
}

extension CodePieceApplication {

	var currentSelectedStatuses: Statuses {
		
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
	
	func moveToFront() {
		
		mainWindow?.makeKeyAndOrderFront(self)
	}

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
	
		currentSelectedStatuses.count == 1
	}
	
	func openBrowserWithCurrentTwitterStatus() {
		
		guard canOpenBrowserWithCurrentTwitterStatus else {
			
			let message = "UNEXPECTED ERROR: Try to open selection with browser, but not ready to open browser. (selection: \(currentSelectedCells.map { $0.row })"
			
			NSLog("%@", message)
//			assertionFailure(message)
			
			return
		}
		
		let selectedStatuses = currentSelectedStatuses

		guard selectedStatuses.count > 0 else {
			
			let message = "UNEXPECTED ERROR: Try to open selection with browser, but don't ready to open current status. (selection: \(currentSelectedStatuses)"
			
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

@MainActor
let NSApp = CodePieceApplication.shared as! CodePieceApplication
