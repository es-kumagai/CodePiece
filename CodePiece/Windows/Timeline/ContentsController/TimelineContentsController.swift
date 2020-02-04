//
//  ContentsController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

class TimelineContentsController : NSObject {
	
	var notificationHandlers = Notification.Handlers()
	@IBOutlet weak var delegate: TimelineContentsControllerDelegate?
	
	func activate() {}
	
	func deactivate() {
		
		notificationHandlers.releaseAll()
	}
	
	deinit {
		
		deactivate()
	}
}

@objc protocol TimelineContentsControllerDelegate : class {

	@objc optional func timelineContentsChanged(_ sender: TimelineContentsController)
}
