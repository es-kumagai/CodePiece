//
//  SearchTweetsWindow.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/08/09.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Cocoa

final class SearchTweetsWindow: NSWindow {

	override func becomeMain() {
		
		super.becomeMain()

		guard let contentViewController = contentViewController as? SearchTweetsViewController else {
			
			return
		}
		
		makeFirstResponder(contentViewController.keywordsTextField)
	}
}
