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
	
	var timelineTableView: TimelineTableView! { get }
	var timelineDataSource: TimelineTableDataSource! { get }
	
	var currentTimelineSelectedRowIndexes: IndexSet { get set }
}

extension TimelineTableControllerType {
	
	var currentTimelineRows: Int {
		
		return self.timelineTableView.numberOfRows
	}
	
	var maxTimelineRows: Int {
		
		return self.timelineDataSource.maxTweets
	}
	
	func appendTweets(tweets: [Status], hashtags: HashtagSet) -> (insertedIndexes: IndexSet, ignoredIndexes: IndexSet, removedIndexes: IndexSet) {

		let tweetCount = tweets.count

		guard tweetCount != 0 else {
		
			return (insertedIndexes: IndexSet(), ignoredIndexes: IndexSet(), removedIndexes: IndexSet())
		}
		
		let currentRows = self.currentTimelineRows
		let maxRows = self.maxTimelineRows
		let insertRows = min(tweetCount, maxRows)
		let overflowRows = max(0, (insertRows + currentRows) - maxRows)
		
		let ignoreRows = max(0, tweetCount - maxRows)

		let getInsertRange = { Range(NSMakeRange(0, insertRows))! }
		let getIgnoreRange = { Range(NSMakeRange(maxRows - ignoreRows, ignoreRows))! }
		let getRemoveRange = { Range(NSMakeRange(currentRows - overflowRows, overflowRows))! }
		
		let insertIndexes = IndexSet(integersIn: getInsertRange())
		let ignoreIndexes = ignoreRows > 0 ? IndexSet(integersIn: getIgnoreRange()) : IndexSet()
		let removeIndexes = overflowRows > 0 ? IndexSet(integersIn: getRemoveRange()) : IndexSet()

		self.timelineDataSource.appendTweets(tweets: tweets, hashtags: hashtags)
		
		applyingExpression(to: self.timelineTableView) {
			
			$0.beginUpdates()
			
			$0.removeRows(at: removeIndexes, withAnimation: [.effectFade, .slideDown])
			$0.insertRows(at: insertIndexes, withAnimation: [.effectFade, .slideDown])
			
			$0.endUpdates()
		}
		
		return (insertedIndexes: insertIndexes, ignoredIndexes: ignoreIndexes, removedIndexes: removeIndexes)
	}
	
	func getNextTimelineSelection(insertedIndexes: IndexSet) -> IndexSet {

		func shiftIndex(currentIndexes: IndexSet, insertIndex: Int) -> IndexSet {
			
			let currentIndexes = currentIndexes.sorted(by: <)

			let noEffectIndexes = currentIndexes.filter { $0 < insertIndex }
			let shiftedIndexes = currentIndexes.filter { $0 >= insertIndex } .map { $0 + 1 }
			
			return IndexSet(noEffectIndexes + shiftedIndexes)
		}

		func shiftIndexes(currentIndexes: IndexSet, insertIndexes: IndexSet) -> IndexSet {
			
			var insertIndexesGenerator = insertIndexes.makeIterator()
			
			if let insertIndex = insertIndexesGenerator.next() {
				
				let currentIndexes = shiftIndex(currentIndexes: currentIndexes, insertIndex: insertIndex)
				let insertIndexes = IndexSet(insertIndexes.dropFirst())

				return shiftIndexes(currentIndexes: currentIndexes, insertIndexes: insertIndexes)
			}
			else {
				
				return currentIndexes
			}
		}
		
        return shiftIndexes(currentIndexes: self.currentTimelineSelectedRowIndexes, insertIndexes: insertedIndexes)
	}
}
