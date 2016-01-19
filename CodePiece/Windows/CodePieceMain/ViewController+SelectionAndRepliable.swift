//
//  ViewController+Repliable.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESTwitter

protocol ViewControllerSelectable : class {
	
	var selectedStatuses: Array<ESTwitter.Status> { get }
}

protocol ViewControllerRepliable : class {
	
	var statusForReplyTo: ESTwitter.Status? { get }
}

protocol ViewControllerSelectionAndRepliable : ViewControllerSelectable, ViewControllerRepliable {
	
	func resetReplyTo()
	func setReplyToBySelectedStatuses()
}

extension ViewControllerSelectable {
	
	var canReplyToSelectedStatuses: Bool {
		
		return selectedStatuses.count == 1
	}
}

extension ViewControllerRepliable {
	
	var hasStatusForReplyTo: Bool {
		
		return statusForReplyTo.isExists
	}
}

extension ViewControllerSelectionAndRepliable {
	
}

extension ViewController {

	@IBAction func setReplyTo(sender: AnyObject) {
		
		if selectedStatuses.isExists {

			setReplyToBySelectedStatuses()
		}
		else {
			
			resetReplyTo()
		}
	}
}
