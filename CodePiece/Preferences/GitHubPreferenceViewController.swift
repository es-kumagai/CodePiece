//
//  GitHubPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean
import ESProgressHUD
import ESNotification
import p2_OAuth2
import ESGists

class GitHubPreferenceViewController: NSViewController {

	private var authenticatingHUD:ProgressHUD = ProgressHUD(message: "Please authentication with in browser which will be opened.\n", useActivityIndicator: true)
	private var removeAuthenticatingHUD:ProgressHUD = ProgressHUD(message: "Authenticating...", useActivityIndicator: true)

	@IBOutlet var authorizedStatusImageView:NSImageView!
	@IBOutlet var authorizedStatusTextField:NSTextField!
	@IBOutlet var authorizedAccountName:NSTextField!
	@IBOutlet var authorizationButton:NSButton!
	@IBOutlet var resetButton:NSButton!
	
	
	@IBAction func doAuthentication(sender:NSButton) {
	
		self.authenticatingHUD.show()
		
		Authorization.authorizationWithGitHub { result in
			
			self.authenticatingHUD.hide()
			
			switch result {
				
			case .Created:
				self.dismissController(self)
				
			case .Failed(let message):
				self.showErrorAlert("Failed to authentication", message: message)
			}
		}
	}
	
	@IBAction func doReset(sender:NSButton) {
		
		guard let id = NSApp.settings.account.id else {
			
			NSApp.settings.resetGitHubAccount(saveFinally: true)
			return
		}
		
		self.removeAuthenticatingHUD.show()
		
		Authorization.resetAuthorizationOfGitHub(id) { result in
			
			self.removeAuthenticatingHUD.hide()
			
			switch result {
				
			case .Success:
				NSLog("Reset successfully. Please perform authentication before you post to Gist again.")
				// self.showInformationAlert("Reset successfully", message: "Please perform authentication before you post to Gist again.")

			case .Failure(let error):
				self.showWarningAlert("Failed to reset authorization", message: "Could't reset the current authentication information. Reset authentication information which saved in this app force. (\(error))")
			}
		}
	}
	
	var authorizationState:AuthorizationState {
		
		return NSApp.settings.account.authorizationState
	}
	
	func applyAuthorizedStatus() {
		
		self.authorizedAccountName.stringValue = NSApp.settings.account.username ?? ""
		
		switch self.authorizationState {
			
		case .Authorized:

			self.authorizedStatusTextField.textColor = SystemColor.TextForAuthenticated.color
			self.authorizedStatusTextField.stringValue = "Authenticated"
			
			self.authorizationButton.enabled = false
			self.resetButton.enabled = true
					
		case .NotAuthorized:
			
			self.authorizedStatusTextField.textColor = SystemColor.TextForNotAuthenticated.color
			self.authorizedStatusTextField.stringValue = "Not authenticated yet"
			
			self.authorizationButton.enabled = true
			self.resetButton.enabled = false
		}
	}
	
    override func viewDidLoad() {

		super.viewDidLoad()
		
		self.applyAuthorizedStatus()

    }
	
	override func viewWillAppear() {
	
		super.viewWillAppear()
		
		Authorization.GitHubAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
			NSLog("Detect GitHub authorization state changed.")
			
			self.applyAuthorizedStatus()
		}
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
	}
}
