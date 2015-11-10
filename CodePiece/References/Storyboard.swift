//
//  Storyboard.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

struct StoryboardItem<InitialController> {

	var name:String
	var initialControllerType:InitialController.Type
	var bundle:NSBundle?
	
	init(name:String, controllerType type: InitialController.Type, bundle:NSBundle? = nil) {
		
		self.name = name
		self.initialControllerType = type
		self.bundle = bundle
	}
	
	var storyboard:NSStoryboard {
		
		return NSStoryboard(name: self.name, bundle: self.bundle)
	}
	
	func getInitialController() throws -> InitialController {
		
		guard let instance = self.storyboard.instantiateInitialController() else {
			
			throw StoryboardError.FailedToGetController
		}
		
		guard let controller = instance as? InitialController else {
			
			throw StoryboardError.UnexpectedControllerType
		}
		
		return controller
	}
}

enum StoryboardError : ErrorType {
	
	case FailedToGetController
	case UnexpectedControllerType
}

struct Storyboard {
	
	static let WelcomeBoard = StoryboardItem(name: "WelcomeBoard", controllerType: WelcomeBoardWindowController.self)
	static let PreferencesWindow = StoryboardItem(name: "PreferencesWindow", controllerType: PreferencesWindowController.self)
	static let GitHubPreferenceView = StoryboardItem(name: "GitHubPreferenceView", controllerType: GitHubPreferenceViewController.self)
	static let TwitterPreferenceView = StoryboardItem(name: "TwitterPreferenceView", controllerType: TwitterPreferenceViewController.self)
}
