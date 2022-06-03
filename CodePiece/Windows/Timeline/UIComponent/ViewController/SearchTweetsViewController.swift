//
//  SearchViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/08/09.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import ESTwitter

@MainActor
@objcMembers
final class SearchTweetsViewController: NSViewController {

	@IBOutlet weak var searchView: NSView!
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

		timelineViewController.view.frame = containerView.bounds
		containerView.addSubview(timelineViewController.view)
    }

	@IBAction func pushSearchButton(_ sender: NSButton) {
		
		contentsController.searchQuery = API.SearchQuery(keywordsTextField.stringValue)
	}
	
	func focusToKeywordsTextField() {
		
		keywordsTextField.becomeFirstResponder()
	}
	
	var currentSelectedCells: [TimelineViewController.SelectingStatusInfo] {
	
		timelineViewController.timelineSelectedStatuses
	}

	var currentSelectedStatuses: [Status] {
		
		currentSelectedCells.compactMap { $0.status }
	}

	dynamic var canReplyTo: Bool {
	
		canReplyToSelectedStatuses
	}

	dynamic var canReplyToSelectedStatuses: Bool {
		
		currentSelectedStatuses.count == 1
	}
}

extension SearchTweetsViewController : NSTextFieldDelegate {

	nonisolated func controlTextDidEndEditing(_ obj: Notification) {
		
		Task { @MainActor in
			
			searchButton.performClick(self)
		}
	}
}
