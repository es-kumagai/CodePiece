//
//  WatermarkStackView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/05/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa

@MainActor
@objcMembers
class WatermarkStackView: NSStackView {

	@IBOutlet var transparentResponder: NSView?
    
	override func mouseDown(with theEvent: NSEvent) {
		
		transparentResponder?.window?.makeFirstResponder(transparentResponder!)
	}
}
