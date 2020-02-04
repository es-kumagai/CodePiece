//
//  TimelineTabViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa

@objc class TimelineTabViewController : NSViewController, NSTabViewDelegate {
	
	var hashtagsTimelineViewController: TimelineViewController!
	var myTweetsTimelineViewController: TimelineViewController!

	@IBOutlet var tabView: NSTabView!
	
	@IBOutlet var timelineKindStateController: TimelineKindStateController!
	
	var currentTimelineKind: TimelineKind? {
		
		return timelineKindStateController.timelineKind
	}
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
		
		hashtagsTimelineViewController = makeTimelineViewController(with: HashtagsContentsController())
		myTweetsTimelineViewController = makeTimelineViewController(with: MyTweetsContentsController())

		addChild(hashtagsTimelineViewController)
		addChild(myTweetsTimelineViewController)
	}
	
	override func viewDidLoad() {

		super.viewDidLoad()
		
		tabView.addTabViewItem(.init(viewController: hashtagsTimelineViewController))
		tabView.addTabViewItem(.init(viewController: myTweetsTimelineViewController))
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		timelineKindStateController.timelineKind = .hashtags
	}
}

extension TimelineTabViewController : TimelineKindStateDelegate {
	
	@objc func timelineKindStateChanged(_ sender: TimelineKindStateController, kind: TimelineKind) {
		
		switch kind {
			
		case .hashtags:
			tabView.selectTabViewItem(at: 0)
			
		case .myTweets:
			tabView.selectTabViewItem(at: 1)
		}
	}
}

private extension TimelineTabViewController {
	
	func makeTimelineViewController(with contentsController: TimelineContentsController) -> TimelineViewController {
		
		let timelineViewController = (storyboard!.instantiateController(withIdentifier: "TimelineViewController") as! TimelineViewController)
	
		timelineViewController.contentsController = contentsController
		
		return timelineViewController
	}
}
