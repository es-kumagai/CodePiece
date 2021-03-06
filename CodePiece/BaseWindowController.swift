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
final class BaseWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
		
		NSLog("Base window did load.")
    }
}

extension BaseWindowController : NSWindowDelegate {
	
	func windowShouldClose(_ sender: NSWindow) -> Bool {
		
		return true
	}
	
	func windowWillClose(_ notification: Notification) {
		
		DebugTime.print("Closing window ...")

		DispatchQueue.main.async {
			
			DebugTime.print("Application will terminate.")
			NSApp.terminate(self)
		}
	}
}
