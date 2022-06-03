//
//  WatermarkLabel.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 3/18/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

@MainActor
@objcMembers
final class WatermarkLabel: NSTextField {

	@IBOutlet var transparentResponder: NSView?
	
	override func mouseDown(with theEvent: NSEvent) {
		
		transparentResponder?.window?.makeFirstResponder(transparentResponder!)
	}
}
