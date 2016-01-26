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

	enum TwitterPreferenceType {
	
		case OAuth
		case OSAccount
		
		var storyboardID: String {
			
			switch self {
				
			case .OAuth:
				return "TwitterByOAuth"
			
			case .OSAccount:
				return "TwitterByOS"
			}
		}
	}
	
	private var twitterPreferenceType: TwitterPreferenceType = .OAuth
	
	@IBOutlet var toolbar:NSToolbar!
	
	@IBAction func showGitHubPreference(sender:NSToolbarItem?) {

		self.contentViewController = try! Storyboard.GitHubPreferenceView.getInitialController()
	}
	
	@IBAction func showTwitterPreference(sender:NSToolbarItem?) {
		
		self.contentViewController = try! Storyboard.TwitterPreferenceView.getControllerByIdentifier(twitterPreferenceType.storyboardID)
	}
	
    override func windowDidLoad() {

		super.windowDidLoad()

		self.contentViewController = try! Storyboard.GitHubPreferenceView.getInitialController()
    }
	
	override func flagsChanged(theEvent: NSEvent) {
		
        DebugTime.print("Modifier flags changed. (\(theEvent.modifierFlags.rawValue))")
        
		if theEvent.modifierFlags.contains(.AlternateKeyMask) {
			
			self.twitterPreferenceType = .OSAccount
		}
		else {
			
			self.twitterPreferenceType = .OAuth
		}
		
		super.flagsChanged(theEvent)
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