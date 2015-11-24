//
//  TimelineTableController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/10.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter
import Swim

protocol TimelineTableControllerType {
	
	var timelineTableView: NSTableView! { get }
	var timelineDataSource: TimelineTableDataSource! { get }
	
	var currentTimelineSelectedRowIndexes: NSIndexSet { get set }
}

extension TimelineTableControllerType {
	
	var currentTimelineRows: Int {
		
		return self.timelineTableView.numberOfRows
	}
	
	var maxTimelineRows: Int {
		
		return self.timelineDataSource.maxTweets
	}
	
	func appendTweets(tweets: [Status], hashtags: HashtagSet) -> (insertedIndexes: NSIndexSet, ignoredIndexes: NSIndexSet, removedIndexes: NSIndexSet) {

		let tweetCount = tweets.count

		guard tweetCount != 0 else {
		
			return (insertedIndexes: NSIndexSet(), ignoredIndexes: NSIndexSet(), removedIndexes: NSIndexSet())
		}
		
		let currentRows = self.currentTimelineRows
		let maxRows = self.maxTimelineRows
		let insertRows = min(tweetCount, maxRows)
		let overflowRows = max(0, (insertRows + currentRows) - maxRows)
		
		let ignoreRows = max(0, tweetCount - maxRows)
		
		let getInsertRange = { NSMakeRange(0, insertRows) }
		let getIgnoreRange = { NSMakeRange(maxRows - ignoreRows, ignoreRows) }
		let getRemoveRange = { NSMakeRange(currentRows - overflowRows, overflowRows) }
		
		let insertIndexes = NSIndexSet(indexesInRange: getInsertRange())
		let ignoreIndexes = ignoreRows > 0 ? NSIndexSet(indexesInRange: getIgnoreRange()) : NSIndexSet()
		let removeIndexes = overflowRows > 0 ? NSIndexSet(indexesInRange: getRemoveRange()) : NSIndexSet()

		self.timelineDataSource.appendTweets(tweets, hashtags: hashtags)
		
		tweak (self.timelineTableView) {
			
			$0.beginUpdates()
			
			$0.removeRowsAtIndexes(removeIndexes, withAnimation: [.EffectFade, .SlideDown])
			$0.insertRowsAtIndexes(insertIndexes, withAnimation: [.EffectFade, .SlideDown])
			
			$0.endUpdates()
		}
		
		return (insertedIndexes: insertIndexes, ignoredIndexes: ignoreIndexes, removedIndexes: removeIndexes)
	}
	
	func getNextTimelineSelection(insertedIndexes: NSIndexSet) -> NSIndexSet {

		func shiftIndex(currentIndexes: NSIndexSet, insertIndex: Int) -> NSIndexSet {
			
			let currentIndexes = currentIndexes.sort(<)

			let noEffectIndexes = currentIndexes.filter { $0 < insertIndex }
			let shiftedIndexes = currentIndexes.filter { $0 >= insertIndex } .map { $0.successor() }
			
			let resultIndexes = NSIndexSet(sequence: noEffectIndexes + shiftedIndexes)
			
			return resultIndexes.copy() as! NSIndexSet
		}

		func shiftIndexes(currentIndexes: NSIndexSet, insertIndexes: NSIndexSet) -> NSIndexSet {
			
			var insertIndexesGenerator = insertIndexes.generate()
			
			if let insertIndex = insertIndexesGenerator.next() {
				
				let currentIndexes = shiftIndex(currentIndexes, insertIndex: insertIndex)
				let insertIndexes = NSIndexSet(sequence: insertIndexes.dropFirst())

				return shiftIndexes(currentIndexes, insertIndexes: insertIndexes)
			}
			else {
				
				return currentIndexes
			}
		}
		
		return shiftIndexes(self.currentTimelineSelectedRowIndexes, insertIndexes: insertedIndexes)
	}
}
