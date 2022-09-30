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

	override func awakeFromNib() {
		
		super.awakeFromNib()
		window?.setFrameAutosaveName("ActivityLogWindow")
	}
	
	override func windowDidLoad() {
		
		super.windowDidLoad()
		contentViewController = LogViewController(size: window!.frame.size)
	}
}
