//
//  GitHubPreferenceAuthenticationViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class GitHubPreferenceAuthenticationViewController: NSViewController {

	@IBOutlet weak var usernameTextField:NSTextField!
	@IBOutlet weak var passwordTextField:NSTextField!
	
	@IBAction func pushCancelButton(sender:NSButton) {
	
		self.dismissViewController(self)
	}
	
	@IBAction func pushAuthenticateButton(sender:NSButton) {
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
