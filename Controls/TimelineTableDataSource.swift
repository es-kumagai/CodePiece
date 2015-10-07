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
import Swim

final class TimelineTableDataSource : NSObject, NSTableViewDataSource {
	
	var tweets = Array<ESTwitter.Status>() {
		
		didSet {
	
			self.lastTweetID = self.tweets.first?.idStr
		}
	}
	
	private(set) var lastTweetID:String?

	func appendTweets(tweets: [ESTwitter.Status]) {
		
		self.tweets = tweets.orderByNewCreationDate() + self.tweets
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		
		return self.tweets.count
	}

	func estimateCellHeightOfRow(row:Int, tableView:NSTableView) -> CGFloat {
		
		// 現行では、実際にビューを作ってサイズを確認しています。
		let view = tweak(tableView.makeViewWithIdentifier("TimelineCell", owner: self) as! TimelineTableCellView) {
			
			$0.willSetStatusForEstimateHeightOnce()
			$0.status = self.tweets[row]
		}
		
		return view.fittingSize.height
	}
}
