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

class GitHubPreferenceViewController: NSViewController {

	private var authenticatingHUD:ProgressHUD = ProgressHUD(message: "Authenticating...", useActivityIndicator: true)

	@IBOutlet weak var authorizedStatusImageView:NSImageView!
	@IBOutlet weak var authorizedStatusTextField:NSTextField!
	@IBOutlet weak var authorizedAccountName:NSTextField!
	@IBOutlet weak var authorizationButton:NSButton!
	@IBOutlet weak var resetButton:NSButton!
	
	
	@IBAction func doAuthentication(sender:NSButton) {
	
		let viewController = self.storyboard!.instantiateControllerWithIdentifier("Authentication") as! GitHubPreferenceAuthenticationViewController

		self.presentViewControllerAsSheet(viewController)
	}
	
	@IBAction func doReset(sender:NSButton) {
		
		guard let id = settings.account.id else {
			
			settings.resetGitHubAccount(saveFinally: true)
			return
		}
		
		self.authenticatingHUD.show()
		
		Authorization.resetAuthorizationOfGitHub(id) { result in
			
			self.authenticatingHUD.hide()
			
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
		
		return settings.account.authorizationState
	}
	
	func applyAuthorizedStatus() {
		
		self.authorizedAccountName.stringValue = settings.account.username ?? ""
		
		switch self.authorizationState {
			
		case .Authorized:

			self.authorizedStatusTextField.textColor = SystemColor.TextForAuthenticated.color
			self.authorizedStatusTextField.stringValue = "Authenticated"
			
			self.authorizationButton.enabled = false
			self.resetButton.enabled = true
		
		case .AuthorizedWithNoToken:
			
			self.authorizedStatusTextField.textColor = SystemColor.TextForAuthenticatedWithNoTalken.color
			self.authorizedStatusTextField.stringValue = "Re-Authentication may be needed"
			
			self.authorizationButton.enabled = true
			self.resetButton.enabled = false
			
			
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
