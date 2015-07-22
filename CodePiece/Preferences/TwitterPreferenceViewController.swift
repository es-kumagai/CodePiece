//
//  TwitterPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class TwitterPreferenceViewController: NSViewController {

	@IBOutlet weak var credentialsVerificationStatusImageView:NSImageView!
	@IBOutlet weak var credentialsVerificationStatusTextField:NSTextField!
	@IBOutlet weak var credentialsVerificationButton:NSButton!
	
	var credentialsNotVerified:Bool {
	
		return !sns.twitter.credentialsVerified
	}
	
	@IBAction func pushVerifyCredentialsButton(sender:NSButton) {
		
		self.willChangeValueForKey("credentialsNotVerified")
		
		sns.twitter.verifyCredentialsIfNeed { result in
			
			self.didChangeValueForKey("credentialsNotVerified")			
			self.applyAuthorizedStatus()
			
			switch result {
				
			case .Success:
				NSLog("Twitter credentials verified successfully.")
				
			case .Failure(let error):
				self.showErrorAlert("Failed to verify credentials", message: String(error))
			}
		}
	}
	
	@IBAction func openPreferences(sender:NSButton) {
		
		NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: "/System/Library/PreferencePanes/InternetAccounts.prefPane"))
	}

	func applyAuthorizedStatus() {
		
		if self.credentialsNotVerified {
			
			self.credentialsVerificationStatusTextField.textColor = SystemColor.TextForAuthenticatedWithNoTalken.color
			self.credentialsVerificationStatusTextField.stringValue = "Need to verify Credentials"
		}
		else {
			
			self.credentialsVerificationStatusTextField.textColor = SystemColor.TextForAuthenticated.color
			self.credentialsVerificationStatusTextField.stringValue = "Credentials Verified"
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		self.applyAuthorizedStatus()
	}
}
