//
//  SearchViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/08/09.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Cocoa

class SearchTweetsViewController: NSViewController {

	@IBOutlet weak var keywordsTextField: NSTextField!
	@IBOutlet weak var containerView: NSView!
	@IBOutlet weak var searchButton: NSButton!
	
	private(set) var timelineViewController: TimelineViewController!
	private(set) var contentsController: SearchTweetsContentsController!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		contentsController = SearchTweetsContentsController()
		timelineViewController = try! Storyboard.timelineViewController.instantiateController()
		
		timelineViewController.contentsController = contentsController

		view.addSubview(timelineViewController.view)
    }
    
	@IBAction func pushSearchButton(_ sender: NSButton) {
		
		let keywords = keywordsTextField.stringValue
		
		contentsController.searchQuery = keywords
	}
}

extension SearchTweetsViewController : NSTextFieldDelegate {

	func controlTextDidEndEditing(_ obj: Notification) {
		
		searchButton.performClick(self)
	}
}
