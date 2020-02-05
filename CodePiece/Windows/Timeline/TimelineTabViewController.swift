//
//  TimelineTabViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import Ocean

@objc class TimelineTabViewController : NSViewController, NSTabViewDelegate, NotificationObservable {
	
	var notificationHandlers = Notification.Handlers()
	var timelineViewControllers: [TimelineViewController] = []

	@IBOutlet var tabView: NSTabView!
	
	@IBOutlet var timelineKindStateController: TimelineKindStateController!
	
	var currentTimelineKind: TimelineKind? {
		
		return timelineKindStateController.timelineKind
	}

	private func prepare() {
		
		timelineKindStateController.prepare()

		let informations = timelineKindStateController.tabInformations.sorted { $0.tabOrder < $1.tabOrder }
		
		for information in informations {
		
			addTimelineViewController(with: information.controller, isKindOf: information.kind, autoUpdateInterval: information.autoUpdateInterval)
		}
		
		timelineViewControllers.activate()
	}
	
	override func viewDidLoad() {

		super.viewDidLoad()

		DebugTime.print("Timeline Tab View Controller did load.")

		observe(notification: CodePieceMainViewDidLoadNotification.self) { [unowned self] notification in

			self.prepare()
		}

		observe(notificationNamed: NSWorkspace.didWakeNotification) { [unowned self] notification in
			
			self.timelineViewControllers.activate()
		}
		
		observe(notificationNamed: NSWorkspace.willSleepNotification) { [unowned self] notification in
			
			self.timelineViewControllers.deactivate()
		}
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		timelineKindStateController.timelineKind = .hashtags
	}
}

extension TimelineTabViewController : TimelineKindStateDelegate {
	
	@objc func timelineKindStateChanged(_ sender: TimelineKindStateController, kind: TimelineKind) {
		
		NSLog("Change timeline tag to '\(kind)'.")
		let foundTarget = timelineViewControllers.enumerated().first { offset, controller in
			
			controller.contentsKind == kind
		}
		
		guard let target = foundTarget else {
			
			fatalError("INTERNAL ERROR: Specified Timeline View Controller that is kind of `\(kind)` is not found.")
		}
		
		tabView.selectTabViewItem(at: target.offset)
	}
}

private extension TimelineTabViewController {
	
	@discardableResult
	func addTimelineViewController(with contentsController: TimelineContentsController, isKindOf kind: TimelineKind, autoUpdateInterval interval: Double? = nil) -> TimelineViewController {
		
		let timelineViewController = (storyboard!.instantiateController(withIdentifier: "TimelineViewController") as! TimelineViewController)
	
		timelineViewController.contentsController = contentsController

		if let interval = interval {
			
			timelineViewController.statusesAutoUpdateInterval = interval
		}

		timelineViewControllers.append(timelineViewController)

		addChild(timelineViewController)
		tabView.addTabViewItem(.init(viewController: timelineViewController))

		return timelineViewController
	}
}
