//
//  Storyboard.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

struct StoryboardItem<Controller> {

	var name:String
	var initialControllerType:Controller.Type
	var bundle: Bundle?
	
	init(name:String, controllerType type: Controller.Type, bundle: Bundle? = nil) {
		
		self.name = name
		self.initialControllerType = type
		self.bundle = bundle
	}
	
	var storyboard:NSStoryboard {
		
		return NSStoryboard(name: self.name, bundle: self.bundle)
	}
	
	func getInitialController() throws -> Controller {
		
		guard let instance = self.storyboard.instantiateInitialController() else {
			
			throw StoryboardError.FailedToGetController
		}
		
		guard let controller = instance as? Controller else {
			
			throw StoryboardError.UnexpectedControllerType
		}
		
		return controller
	}
	
	func getControllerByIdentifier(identifier: String) throws -> Controller {

		let instance = self.storyboard.instantiateController(withIdentifier: identifier)
		
		guard let controller = instance as? Controller else {
			
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
	
	static let WelcomeBoard = StoryboardItem(name: "WelcomeBoard", controllerType: WelcomeBoardWindowController.self)
	static let PreferencesWindow = StoryboardItem(name: "PreferencesWindow", controllerType: PreferencesWindowController.self)
	static let GitHubPreferenceView = StoryboardItem(name: "GitHubPreferenceView", controllerType: GitHubPreferenceViewController.self)
	static let TwitterPreferenceView = StoryboardItem(name: "TwitterPreferenceView", controllerType: TwitterPreferenceViewController.self)
}
