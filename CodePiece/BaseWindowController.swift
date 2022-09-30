//
//  BaseWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import CodePieceCore

@objcMembers
@MainActor
final class BaseWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		
		DebugTime.print("Base window did load.")
    }
}

extension BaseWindowController : NSWindowDelegate {
	
	nonisolated func windowShouldClose(_ sender: NSWindow) -> Bool {
		
		return true
	}
	
	nonisolated func windowWillClose(_ notification: Notification) {
		
		DebugTime.print("Closing window ...")

		Task { @MainActor in
			
			DebugTime.print("Application will terminate.")
			NSApp.terminate(self)
		}
	}
}
