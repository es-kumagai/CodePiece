//
//  BaseWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class BaseWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

		if let info = NSBundle.mainBundle().infoDictionary, let buildVersion = info["CFBundleVersion"] {
			
			if let window = self.window {
				
				self.window?.title = "\(window.title) (build: \(buildVersion))"
			}
		}

		// FIXME: @koogawa さんの環境で何も表示されないらしいので、応急措置を講じてみました。
		if self.contentViewController == nil {
			
			if let window = self.window {
				
				self.window?.title = "\(window.title) (Fix:#1)"
			}

			let controller = self.storyboard?.instantiateControllerWithIdentifier("MainViewController") as? NSViewController

			self.contentViewController = controller
		}
    }

}
