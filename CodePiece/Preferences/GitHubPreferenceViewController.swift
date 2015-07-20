//
//  GitHubPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class GitHubPreferenceViewController: NSViewController {

	@IBOutlet weak var authorizedStatusImageView:NSImageView!
	@IBOutlet weak var authorizedStatusTextField:NSTextField!
	
	@IBAction func doAuthentication(sender:NSButton) {
	
	}
	
	@IBAction func doReset(sender:NSButton) {
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
