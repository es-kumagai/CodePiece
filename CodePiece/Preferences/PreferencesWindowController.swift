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
	
	@IBAction func showAccountsPreference(sender:NSToolbarItem?) {
		
		self.contentViewController = Storyboard.AccountsPreferenceView.defaultViewController
	}
	
	@IBAction func showGitHubPreference(sender:NSToolbarItem?) {

		self.contentViewController = Storyboard.GitHubPreferenceView.defaultViewController
	}
	
	@IBAction func showTwitterPreference(sender:NSToolbarItem?) {
		
		self.contentViewController = Storyboard.TwitterPreferenceView.defaultViewController
	}
	
    override func windowDidLoad() {

		super.windowDidLoad()

		self.contentViewController = Storyboard.AccountsPreferenceView.defaultViewController
    }
}

extension PreferencesWindowController : NSWindowDelegate {
	
	func windowWillClose(notification: NSNotification) {

		sns.twitter.verifyCredentialsIfNeed { result in
			
			if let error = result.error {
				
				NSLog("Failed to verify credentials. \(error)")
			}
		}
	}
}