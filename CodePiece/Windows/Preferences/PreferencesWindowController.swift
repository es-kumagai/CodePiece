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

@objcMembers
final class PreferencesWindowController: NSWindowController {

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
	
	@IBAction func showGitHubPreference(_ sender:NSToolbarItem?) {

		self.contentViewController = try! Storyboard.GitHubPreferenceView.getInitialController()
	}
	
	@IBAction func showTwitterPreference(_ sender:NSToolbarItem?) {
		
		self.contentViewController = try! Storyboard.TwitterPreferenceView.getControllerByIdentifier(identifier: twitterPreferenceType.storyboardID)
	}
	
    override func windowDidLoad() {

		super.windowDidLoad()

		self.contentViewController = try! Storyboard.GitHubPreferenceView.getInitialController()
    }
	
	override func flagsChanged(with theEvent: NSEvent) {
		
        DebugTime.print("Modifier flags changed. (\(theEvent.modifierFlags.rawValue))")

		if theEvent.modifierFlags.contains(.option) {
			
			self.twitterPreferenceType = .OSAccount
		}
		else {
			
			self.twitterPreferenceType = .OAuth
		}
		
		super.flagsChanged(with: theEvent)
	}
}

extension PreferencesWindowController {
	
	override func showWindow(_ sender: Any?) {
		
		NSApp.runModal(for: window!)
	}
}

extension PreferencesWindowController : NSWindowDelegate {
	
	func windowWillClose(_ notification: Notification) {
		
		NSApp.stopModal(withCode: .OK)
		NSApp.twitterController.verifyCredentialsIfNeed { result in
			
			if case .failure(let error) = result {
				
				NSLog("Failed to verify credentials. \(error)")
			}
		}
	}
}