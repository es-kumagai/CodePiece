//
//  LogWindowController.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/09/30
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import AppKit

@MainActor
@objcMembers
final class LogWindowController : NSWindowController {

	override func windowDidLoad() {
		
		super.windowDidLoad()

		// For some reason, this method is called twice,
		// so the initialization of the content view controller is
		// made to executed only once.
		if contentViewController == nil {

			contentViewController = LogViewController(minSize: window!.minSize)
		}
	}
}
