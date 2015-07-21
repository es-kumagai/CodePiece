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
	
		self.dismissController(self)
	}
	
	@IBAction func pushAuthenticateButton(sender:NSButton) {
		
		let username = self.usernameTextField.stringValue
		let password = self.passwordTextField.stringValue
		
		guard !username.isEmpty && !password.isEmpty else {

			self.showErrorAlert("Invalid account", message: "Please enter your 'Username' and 'Password' for GitHub.")
			return
		}
		
		Authorization.authorizationWithGitHub(username, password: password) { result in
			
			switch result {
				
			case .Created:
				self.dismissController(self)
				
			case .AlreadyCreated:
				self.showInformationAlert("Already authenticated", message: "If you cannot post a code to Gist, please 'reset' authentication and authenticate again.")
				self.dismissController(self)
				
			case .Failed(let message):
				self.showErrorAlert("Failed to authentication", message: message)
			}
		}
	}
	
    override func viewDidLoad() {

		super.viewDidLoad()
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		if let username = settings.account.username {
			
			self.usernameTextField.stringValue = username
			self.passwordTextField.becomeFirstResponder()
		}
	}
}
