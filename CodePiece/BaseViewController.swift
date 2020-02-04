//
//  BaseViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
final class BaseViewController: NSSplitViewController {

	private(set) weak var mainSplitViewItem: NSSplitViewItem? {
		
		didSet {
			
			mainViewController = mainSplitViewItem.map { $0.viewController as! MainViewController }
		}
	}

	private(set) weak var timelineSplitViewItem: NSSplitViewItem? {
		
		didSet {
			
			timelineViewController = timelineSplitViewItem.map { $0.viewController as! TimelineViewController }
		}
	}

	private(set) weak var mainViewController: MainViewController?
	private(set) weak var timelineViewController: TimelineViewController?
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
		
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		for item in splitViewItems {
			
			switch item.viewController {
				
			case is MainViewController:
				mainSplitViewItem = item
				
			case is TimelineViewController:
				timelineSplitViewItem = item
				
			default:
				break
			}
		}
	}
	
	override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
		
		return .zero
	}
}
