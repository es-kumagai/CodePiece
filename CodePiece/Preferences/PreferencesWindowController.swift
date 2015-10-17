//
//  PreferencesWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

enum PreferencesWindowModalResult : Int {

	case Close = 0
}

class PreferencesWindowController: NSWindowController {

	@IBOutlet weak var toolbar:NSToolbar!
	
	@IBAction func showGitHubPreference(sender:NSToolbarItem?) {

		self.contentViewController = try! Storyboard.GitHubPreferenceView.getInitialController()
	}
	
	@IBAction func showTwitterPreference(sender:NSToolbarItem?) {
		
		self.contentViewController = try! Storyboard.TwitterPreferenceView.getInitialController()
	}
	
    override func windowDidLoad() {

		super.windowDidLoad()

		self.contentViewController = try! Storyboard.GitHubPreferenceView.getInitialController()
    }
}

extension PreferencesWindowController : NSWindowDelegate {
	
	func windowWillClose(notification: NSNotification) {

		NSApp.twitterController.verifyCredentialsIfNeed { result in
			
			if let error = result.error {
				
				NSLog("Failed to verify credentials. \(error)")
			}
		}
	}
}