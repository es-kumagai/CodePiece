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
	
	func canOpenTwitterHome() -> Bool {

		return sns?.twitter.credentialsVerified ?? false
	}
	
	func openTwitterHome() {
		
		guard let username = sns.twitter.account?.username else {
		
			return self.showErrorAlert("Failed to open Twitter", message: "Twitter user is not set.")
		}
		
		do {

			try ESTwitter.Browser.openWithUsername(username)
		}
		catch ESTwitter.Browser.Error.OperationFailure(reason: let reason) {
			
			self.showErrorAlert("Failed to open Twitter", message: reason)
		}
		catch {
			
			self.showErrorAlert("Failed to open Twitter", message: "Unknown Error : \(error)")
		}
	}

	func canOpenGitHubHome() -> Bool {
		
		return settings?.account.authorizationState.isValid ?? false
	}
	
	func openGitHubHome() {
		
		guard let username = settings.account.username else {
			
			return self.showErrorAlert("Failed to open GitHub", message: "GitHub user is not set.")
		}
		
		let urlString = "https://GitHub.com/\(username)"
		
		guard let url = NSURL(string: urlString) else {
			
			return self.showErrorAlert("Failed to open GitHub", message: "Invalid URL '\(urlString)'.")
		}

		NSWorkspace.sharedWorkspace().openURL(url).ifFalse {

			self.showErrorAlert("Failed to open GitHub", message: "URL '\(url)' cannot open.")
		}
	}
}
