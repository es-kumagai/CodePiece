//
//  TimelineViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class TimelineViewController: NSViewController {

	@IBOutlet weak var timelineTableView:NSTableView!
	@IBOutlet weak var timelineDataSource:TimelineTableDataSource!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		HashtagDidChangeNotification.observeBy(self) { owner, notification in
			
			let hashtag = notification.hashtag
			
			NSLog("Hashtag did change (\(hashtag))")
			
			self.timelineDataSource.hashtag = hashtag
		}
    }
}
