//
//  Storyboard.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

enum Storyboard : String {
	
	case PreferencesWindow
	case GitHubPreferenceView
	case TwitterPreferenceView
	
	var storyboard:NSStoryboard {
		
		return NSStoryboard(name: self.rawValue, bundle: nil)
	}
	
	var defaultController:AnyObject {
		
		return self.storyboard.instantiateInitialController()!
	}
	
	var defaultWindowController:NSWindowController {
		
		return self.defaultController as! NSWindowController
	}
	
	var defaultViewController:NSViewController {
		
		return self.defaultController as! NSViewController
	}
}

