//
//  GistPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean
import ESProgressHUD
import ESTwitter
import ESGists

@objcMembers
final class GistPreferenceViewController: NSViewController, NotificationObservable {

	var notificationHandlers = Notification.Handlers()
	
	private var authenticatingHUD = ProgressHUD(message: "Please authenticate with the launched browser.\n", useActivityIndicator: true)
	private var removeAuthenticatingHUD = ProgressHUD(message: "Authenticating...", useActivityIndicator: true)

	@IBOutlet var authorizedStatusImageView: NSImageView!
	@IBOutlet var authorizedStatusTextField: NSTextField!
	@IBOutlet var authorizedAccountName: NSTextField!
	@IBOutlet var authorizationButton: NSButton!
	@IBOutlet var resetButton: NSButton!
	
	
	@IBAction func doAuthentication(_ sender:NSButton) {
	
		authenticatingHUD.show()
		
		Authorization.authorizationWithGist { result in
			
			self.authenticatingHUD.hide()
			
			switch result {
				
			case .Created:
				NSLog("%@", "GitHub authentication succeeded.")
				
			case .Failed(let error):
				NSLog("Failed to authentication. %@", "\(error)")
				
//			case .PinRequired:
//				self.showErrorAlert(withTitle: "Failed to authentication", message: "Unexpected Process (Pin Required).")
			}
		}
	}
	
	@IBAction func doReset(_ sender:NSButton) {
		
		guard let id = NSApp.settings.account.id else {
			
			NSApp.settings.resetGistAccount(saveFinally: true)
			return
		}
		
		self.removeAuthenticatingHUD.show()
		
		Authorization.resetAuthorizationOfGist(id: id) { result in
			
			self.removeAuthenticatingHUD.hide()
			
			switch result {
				
			case .success:
				NSLog("Reset successfully. Please authenticate before you post to Gist again.")
				// self.showInformationAlert("Reset successfully", message: "Please perform authentication before you post to Gist again.")

			case .failure(let error):
				self.showWarningAlert(withTitle: "Failed to reset authentication", message: "Could't reset the current authentication information correctly. Reset authentication information force. (\(error))")
			}
		}
	}
	
	var authorizationState:AuthorizationState {
		
		return NSApp.settings.account.authorizationState
	}
	
	func applyAuthorizedStatus() {
		
		authorizedAccountName.stringValue = NSApp.settings.account.username ?? ""
		
		switch authorizationState {
			
		case .authorized:

			authorizedStatusTextField.textColor = .authenticatedForegroundColor
			authorizedStatusTextField.stringValue = "Authenticated"
			
			authorizationButton.isEnabled = false
			resetButton.isEnabled = true
					
		case .notAuthorized:
			
			authorizedStatusTextField.textColor = .notAuthenticatedForegroundColor
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
		
		observe(notification: Authorization.GistAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			NSLog("Detect GitHub authorization state changed.")
			
			self.applyAuthorizedStatus()
		}
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
	}
}
