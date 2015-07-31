//
//  AboutWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/31.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

public class AboutWindowController: NSWindowController {

    public override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	public static func instantiate() -> AboutWindowController {
		
		let storyboard = NSStoryboard(name: "AboutWindowController", bundle: nil)
		
		return self.instantiate(storyboard)!
	}
	
	public static func instantiate(storyboard:NSStoryboard, identifier:String? = nil) -> AboutWindowController? {

		if let identifier = identifier {

			return storyboard.instantiateControllerWithIdentifier(identifier) as? AboutWindowController
		}
		else {
			
			return storyboard.instantiateInitialController() as? AboutWindowController
		}
	}

	public override var contentViewController: NSViewController? {
	
		get {
			
			return super.contentViewController
		}
		
		set {
			
			fatalError("Not supported.")
		}
	}
	
	public var aboutViewController: AboutViewController {
	
		return super.contentViewController as! AboutViewController
	}
	
	public var acknowledgementsName:String? {
		
		didSet {
			
			self.aboutViewController.acknowledgementsName = self.acknowledgementsName
		}
	}
	
	public var hasAcnowledgements:Bool {
		
		return self.acknowledgementsName != nil
	}
	
	public func showWindow() {
		
		self.showWindow(self)
	}
}
