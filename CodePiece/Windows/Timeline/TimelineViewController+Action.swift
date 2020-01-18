//
//  TimelineViewController+Action.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/09.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

extension TimelineViewController {
	
	@IBAction func pushTimelineRefreshButton(_ sender: AnyObject!) {
		
		self.reloadTimeline()
	}
}
