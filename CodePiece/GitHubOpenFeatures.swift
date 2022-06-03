//
//  GitHubOpenFeatures.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/11.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import Ocean

@objcMembers
@MainActor
final class GitHubOpenFeatures : NSObject, AlertDisplayable {

	var notificationHandlers = Notification.Handlers()

	override init() {
		
		super.init()

		notificationHandlers.observe(Authorization.GistAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			withChangeValue(for: "canOpenGitHubHome")
		}
	}
	
	dynamic var canOpenGitHubHome: Bool {
		
		guard NSApp.isPrepared else {
			
			return false
		}

		return NSApp.settings.account.authorizationState.isValid
	}
	
	@IBAction func openGitHubHomeAction(_ sender:AnyObject) {
	
		openGitHubHome()
	}
	
	func openGitHubHome() {

		guard let username = NSApp.settings.account.username else {
			
			showErrorAlert(withTitle: "Failed to open GitHub", message: "GitHub user is not set.")
			return
		}
		
		let urlString = "https://GitHub.com/\(username)"
		
		guard let url = URL(string: urlString) else {
			
			showErrorAlert(withTitle: "Failed to open GitHub", message: "Invalid URL '\(urlString)'.")
			return
		}
		
		NSWorkspace.shared.open(url).isFalse {
			
			showErrorAlert(withTitle: "Failed to open GitHub", message: "URL '\(url)' cannot open.")
		}
	}
}
