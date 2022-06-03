//
//  Storyboard.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

struct StoryboardItem<Controller> {

	var name: String
	var initialControllerType: Controller.Type
	var bundle: Bundle?
	var identifier: String?
	
	init(name:String, controllerType type: Controller.Type, identifier: String? = nil, bundle: Bundle? = nil) {
		
		self.name = name
		self.initialControllerType = type
		self.identifier = identifier
		self.bundle = bundle
	}
	
	var storyboard: NSStoryboard {
		
		NSStoryboard(name: name, bundle: bundle)
	}
	
	@MainActor
	func instantiateController() throws -> Controller {
	
		if let identifier = identifier {
			
			return try instantiateController(withIdentifier: identifier)
		}
		else {
			
			return try instantiateInitialController()
		}
	}

	@MainActor
	func instantiateInitialController() throws -> Controller {
		
		guard let instance = storyboard.instantiateInitialController() else {
			
			throw StoryboardError.FailedToGetController
		}
		
		guard let controller = instance as? Controller else {
			
			throw StoryboardError.UnexpectedControllerType
		}
		
		return controller
	}
	
	@MainActor
	func instantiateController(withIdentifier identifier: String) throws -> Controller {

		guard let controller = storyboard.instantiateController(withIdentifier: identifier) as? Controller else {
			
			throw StoryboardError.UnexpectedControllerType
		}
		
		return controller
	}
}

enum StoryboardError : Error {
	
	case FailedToGetController
	case UnexpectedControllerType
}

struct Storyboard {
	
	static let welcomeBoard = StoryboardItem(name: "WelcomeBoard", controllerType: WelcomeBoardWindowController.self)
	static let preferencesWindow = StoryboardItem(name: "PreferencesWindow", controllerType: PreferencesWindowController.self)
	static let gistPreferenceView = StoryboardItem(name: "GistPreferenceView", controllerType: GistPreferenceViewController.self)
	static let twitterPreferenceView = StoryboardItem(name: "TwitterPreferenceView", controllerType: TwitterPreferenceViewController.self)
	
	static let timelineViewController = StoryboardItem(name: "Timeline", controllerType: TimelineViewController.self, identifier: "TimelineViewController")
	static let searchTweetsWindow = StoryboardItem(name: "Timeline", controllerType: SearchTweetsWindowController.self, identifier: "SearchTweetsWindowController")
}
