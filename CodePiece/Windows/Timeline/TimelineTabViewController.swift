//
//  TimelineTabViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import Ocean
import ESTwitter
import CodePieceCore

@objc class TimelineTabViewController : NSViewController, NSTabViewDelegate, NotificationObservable {
	
	var notificationHandlers = Notification.Handlers()
	var timelineViewControllers: [TimelineViewController] = []

	@IBOutlet var tabView: NSTabView!
	
	@IBOutlet var timelineKindStateController: TimelineKindStateController!
	
	var currentTimelineKind: TimelineKind? {
		
		get {

			return timelineKindStateController.timelineKind
		}
		
		set (kind) {
			
			timelineKindStateController.timelineKind = kind
		}
	}

	var currentSelectedCells: [TimelineViewController.SelectingStatusInfo] {
	
		guard let timelineViewController = currentTimelineViewController else {
			
			return []
		}
		
		return timelineViewController.timelineSelectedStatuses
	}
	
	var currentSelectedStatuses: [Status] {
		
		return currentSelectedCells.compactMap { $0.status }
	}
	
	var isCurrentSingleRowSelected: Bool {
		
		return currentSelectedCells.count == 1
	}
	
	var isCurrentSingleOrMoreRowsSelected: Bool {
		
		return currentSelectedCells.count > 0
	}
	
	private func prepare() {
		
		timelineKindStateController.prepare()

		let informations = timelineKindStateController.tabInformations.sorted { $0.tabOrder < $1.tabOrder }
		
		for information in informations {
		
			addTimelineViewController(with: information.controller, autoUpdateInterval: information.autoUpdateInterval)
		}
		
		timelineViewControllers.activate()
	}
	
	override func viewDidLoad() {

		super.viewDidLoad()

		DebugTime.print("Timeline Tab View Controller did load.")

		observe(CodePieceMainViewDidLoadNotification.self) { [unowned self] notification in

			prepare()
		}

		observe(notificationNamed: NSWorkspace.didWakeNotification) { [unowned self] notification in
			
			timelineViewControllers.activate()
		}
		
		observe(notificationNamed: NSWorkspace.willSleepNotification) { [unowned self] notification in
			
			timelineViewControllers.deactivate()
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

extension TimelineTabViewController {
	
	var currentTimelineViewController: TimelineViewController? {
	
		guard let kind = currentTimelineKind else {
			
			return nil
		}

		return timelineViewController(of: kind)
	}
	
	var currentTimelineContentsController: TimelineContentsController? {
	
		guard let kind = currentTimelineKind else {
			
			return nil
		}

		return timelineViewController(of: kind).contentsController
	}
	
	func timelineViewController(of kind: TimelineKind) -> TimelineViewController {
	
		guard let viewController = timelineViewControllers.first(where: { $0.contentsKind == kind }) else {
			
			fatalError("INTERNAL ERROR: Unknown kind '\(kind)' of Timeline View Controller specified.")
		}
		
		return viewController
	}
	
	func timelineContentsController(of kind: TimelineKind) -> TimelineContentsController {
	
		return timelineViewController(of: kind).contentsController
	}
}

private extension TimelineTabViewController {
	
	@discardableResult
	func addTimelineViewController(with contentsController: TimelineContentsController, autoUpdateInterval interval: Double? = nil) -> TimelineViewController {
		
		let timelineViewController = try! Storyboard.timelineViewController.instantiateController()

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
