//
//  SearchWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/08/09.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Cocoa

@objcMembers
@MainActor
class SearchTweetsWindowController: NSWindowController, NSWindowDelegate {

	@IBOutlet weak var delegate: SearchTweetsWindowControllerDelegate?
	
    override func windowDidLoad() {
        super.windowDidLoad()
    
    }

//	func windowWillMove(_ notification: Notification) {
//
//		guard let contentViewController = contentViewController as? SearchTweetsViewController else {
//			
//			return
//		}
//		
//		let targetTextField = contentViewController.keywordsTextField
//		
//		targetTextField?.becomeFirstResponder()
//	}
	
	nonisolated func windowDidBecomeKey(_ notification: Notification) {
		
	}
	
	nonisolated func windowWillClose(_ notification: Notification) {
		
		Task { @MainActor in
			
			delegate?.searchTweetsWindowControllerWillClose(self)
		}
	}
}
