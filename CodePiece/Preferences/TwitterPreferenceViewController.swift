//
//  TwitterPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESProgressHUD
import Ocean
import Swim
import Accounts

class TwitterPreferenceViewController: NSViewController {

	private var verifyingHUD:ProgressHUD = ProgressHUD(message: "Verifying...", useActivityIndicator: true)
	private var waitingHUD:ProgressHUD = ProgressHUD(message: "Please wait...", useActivityIndicator: true)

	@IBOutlet weak var credentialsVerificationStatusImageView:NSImageView!
	@IBOutlet weak var credentialsVerificationStatusTextField:NSTextField!
	@IBOutlet weak var credentialsVerificationButton:NSButton!
	@IBOutlet weak var selectedAccountName:NSTextField!
	
	@IBOutlet weak var errorReportTextField:NSTextField? {
		
		didSet {
			
			self.clearError()
		}
	}
	
	@IBOutlet weak var accountSelectorController:TwitterAccountSelectorController!
	
	var credentialsNotVerified:Bool {
	
		// FIXME: 🌙 モーダル画面でベリファイしようとすると、メインスレッドで実行しているからか、閉じるまでベリファイ作業が継続されない。
		return !sns.twitter.credentialsVerified
	}
	
	@IBAction func pushVerifyCredentialsButton(sender:NSButton) {
		
		self.willChangeValueForKey("credentialsNotVerified")
		
		self.verifyingHUD.show()
		
		sns.twitter.verifyCredentialsIfNeed { result in

			self.didChangeValueForKey("credentialsNotVerified")
			self.applyAuthorizedStatus()
			
			self.verifyingHUD.hide()
			
			switch result {
				
			case .Success:
				NSLog("Twitter credentials verified successfully.")
				
			case .Failure(let error):
				self.showErrorAlert("Failed to verify credentials", message: String(error))
			}
		}
	}
	
	@IBAction func openAccountsPreferences(sender:NSButton) {
		
		self.openSystemPreferences("InternetAccounts")
	}

	@IBAction func openSecurityPreferences(sender:NSButton) {

		// TODO: I want to open Security preferences directly.
		self.openSystemPreferences("Security")
	}
	
	func openSystemPreferences(panel:String) {
	
		// 表示に時間がかかるので、気持ち待ち時間を HUD で紛らわします。
		waitingHUD.show()
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(6 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
			
			self.waitingHUD.hide()
		}
		
		NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: "/System/Library/PreferencePanes/\(panel).prefPane"))
	}
	
	func applyAuthorizedStatus() {
		
		self.selectedAccountName.stringValue = sns.twitter.username ?? ""
		
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

		sns.twitter.requestAccessToAccounts { result in
			
			switch result {
				
			case .Success:
				NSLog("Access to Twitter account is allowed.")
				self.clearError()
				
			case .Failure(let error):
				NSLog("Access to Twitter account is not allowed. \(error)")
				self.reportError("Access to Twitter account is not allowed. Please give permission to access Twitter account using Privacy settings.")
			}
		}
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		self.applyAuthorizedStatus()
	}
	
	override func viewDidAppear() {
		
		super.viewDidAppear()
		
	}
		
	func clearError() {
	
		self.reportError("")
	}
	
	func reportError(message:String) {
		
		if !message.isEmpty {
			
			NSLog(message)
		}
		
		self.errorReportTextField?.stringValue = message
	}
}
