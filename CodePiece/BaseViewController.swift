//
//  BaseViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class BaseViewController: NSSplitViewController {

	private(set) weak var mainSplitViewItem:NSSplitViewItem? {
		
		didSet {
			
			self.mainViewController = self.mainSplitViewItem.map { $0.viewController as! ViewController }
		}
	}

	private(set) weak var timelineSplitViewItem:NSSplitViewItem? {
		
		didSet {
			
			self.timelineViewController = self.mainSplitViewItem.map { $0.viewController as! TimelineViewController }
		}
	}

	private(set) weak var mainViewController:ViewController?
	private(set) weak var timelineViewController:TimelineViewController?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		for item in self.splitViewItems {
			
			switch item.viewController {
				
			case is ViewController:
				self.mainSplitViewItem = item
				
			case is TimelineViewController:
				self.timelineSplitViewItem = item
				
			default:
				break
			}
		}
	}
}
