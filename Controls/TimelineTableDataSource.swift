//
//  TimelineDataSource.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2015/08/24.
//  Copyright © 2015年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import APIKit
import ESTwitter

final class TimelineTableDataSource : NSObject, NSTableViewDataSource {
	
	var tweets = Array<ESTwitter.Status>()
	
	func appendTweets(tweets: [ESTwitter.Status]) {
		
		self.tweets = tweets + self.tweets
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		
		return self.tweets.count
	}

	func estimateCellHeightOfRow(row:Int) -> CGFloat {
		
		return 60.0
	}
}
