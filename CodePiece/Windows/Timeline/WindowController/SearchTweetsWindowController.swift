//
//  SearchWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/08/09.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Cocoa

class SearchTweetsWindowController: NSWindowController, NSWindowDelegate {

	@IBOutlet weak var delegate: SearchTweetsWindowControllerDelegate?
	
    override func windowDidLoad() {
        super.windowDidLoad()
    
    }

	func windowWillClose(_ notification: Notification) {
		
		delegate?.searchTweetsWindowControllerWillClose(self)
	}
}
