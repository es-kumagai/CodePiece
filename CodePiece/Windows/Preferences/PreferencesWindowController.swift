//
//  PreferencesWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import CodePieceCore

enum PreferencesWindowModalResult : Int {

	case Close = 0
}

@objcMembers
@MainActor
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
	
	@IBOutlet var toolbar: NSToolbar!
	
	@IBAction func showGitHubPreference(_ sender: NSToolbarItem?) {

		contentViewController = try! Storyboard.gistPreferenceView.instantiateController()
	}
	
	@IBAction func showTwitterPreference(_ sender: NSToolbarItem?) {
		
		contentViewController = try! Storyboard.twitterPreferenceView.instantiateController(withIdentifier: twitterPreferenceType.storyboardID)
	}
	
    override func windowDidLoad() {

		super.windowDidLoad()

		// runModal だと認証時の URL Scheme アクセスを受信できなくなるため Floating で対応します。
		window!.hidesOnDeactivate = true
		window!.level = .floating

		contentViewController = try! Storyboard.gistPreferenceView.instantiateController()
    }
	
	override func flagsChanged(with theEvent: NSEvent) {
		
        DebugTime.print("Modifier flags changed. (\(theEvent.modifierFlags.rawValue))")

		if theEvent.modifierFlags.contains(.option) {
			
			twitterPreferenceType = .OSAccount
		}
		else {
			
			twitterPreferenceType = .OAuth
		}
		
		super.flagsChanged(with: theEvent)
	}
}

extension PreferencesWindowController {
	
	override func showWindow(_ sender: Any?) {

		super.showWindow(sender)
//		NSApp.runModal(for: window!)
	}
	
	override func close() {
		
//		NSApp.stopModal(withCode: .OK)
		super.close()
	}
}

extension PreferencesWindowController : NSWindowDelegate {
	
	nonisolated func windowWillClose(_ notification: Notification) {

//		Task { @MainActor in
//
//			NSApp.stopModal(withCode: .OK)
//		}
//		NSApp.twitterController.verifyCredentialsIfNeed { result in
//			
//			if case .failure(let error) = result {
//				
//				NSLog("Failed to verify credentials. \(error)")
//			}
//		}
	}
}
