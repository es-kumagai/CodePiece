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
import OAuth2
import ESGists

class GitHubPreferenceViewController: NSViewController, NotificationObservable {

	var notificationHandlers = Notification.Handlers()
	
	private var authenticatingHUD:ProgressHUD = ProgressHUD(message: "Please authentication with in browser which will be opened.\n", useActivityIndicator: true)
	private var removeAuthenticatingHUD:ProgressHUD = ProgressHUD(message: "Authenticating...", useActivityIndicator: true)

	@IBOutlet var authorizedStatusImageView:NSImageView!
	@IBOutlet var authorizedStatusTextField:NSTextField!
	@IBOutlet var authorizedAccountName:NSTextField!
	@IBOutlet var authorizationButton:NSButton!
	@IBOutlet var resetButton:NSButton!
	
	
	@IBAction func doAuthentication(sender:NSButton) {
	
		authenticatingHUD.show()
		
		Authorization.authorizationWithGitHub { result in
			
			authenticatingHUD.hide()
			
			switch result {
				
			case .Created:
				dismiss(self)
				
			case .Failed(let message):
				showErrorAlert(withTitle: "Failed to authentication", message: message.localizedDescription)
				
			case .PinRequired:
				showErrorAlert(withTitle: "Failed to authentication", message: "Unexpected Process (Pin Required).")
			}
		}
	}
	
	@IBAction func doReset(sender:NSButton) {
		
		guard let id = NSApp.settings.account.id else {
			
			NSApp.settings.resetGitHubAccount(saveFinally: true)
			return
		}
		
		self.removeAuthenticatingHUD.show()
		
		Authorization.resetAuthorizationOfGitHub(id: id) { result in
			
			removeAuthenticatingHUD.hide()
			
			switch result {
				
			case .success:
				NSLog("Reset successfully. Please perform authentication before you post to Gist again.")
				// self.showInformationAlert("Reset successfully", message: "Please perform authentication before you post to Gist again.")

			case .failure(let error):
				showWarningAlert(withTitle: "Failed to reset authorization", message: "Could't reset the current authentication information. Reset authentication information which saved in this app force. (\(error))")
			}
		}
	}
	
	var authorizationState:AuthorizationState {
		
		return NSApp.settings.account.authorizationState
	}
	
	func applyAuthorizedStatus() {
		
		authorizedAccountName.stringValue = NSApp.settings.account.username ?? ""
		
		switch authorizationState {
			
		case .Authorized:

			authorizedStatusTextField.textColor = SystemColor.TextForAuthenticated.color
			authorizedStatusTextField.stringValue = "Authenticated"
			
			authorizationButton.isEnabled = false
			resetButton.isEnabled = true
					
		case .NotAuthorized:
			
			authorizedStatusTextField.textColor = SystemColor.TextForNotAuthenticated.color
			authorizedStatusTextField.stringValue = "Not authenticated yet"
			
			authorizationButton.isEnabled = true
			resetButton.isEnabled = false
		}
	}
	
    override func viewDidLoad() {

		super.viewDidLoad()
		
		self.applyAuthorizedStatus()

    }
	
	override func viewWillAppear() {
	
		super.viewWillAppear()
		
		observe(notification: Authorization.GitHubAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			NSLog("Detect GitHub authorization state changed.")
			
			self.applyAuthorizedStatus()
		}
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
	}
}
