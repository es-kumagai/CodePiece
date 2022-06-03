//
//  WelcomeBoardWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
@MainActor
final class WelcomeBoardWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
	
	override func showWindow(_ sender: Any?) {
		
		NSApp.runModal(for: window!)
	}

	override func close() {
		
		NSApp.stopModal(withCode: .OK)
		super.close()
	}
	
	nonisolated func windowWillClose(_ notification: Notification) {
	
//		Task { @MainActor in
//
//			NSApp.stopModal(withCode: .OK)
//		}
	}
}
