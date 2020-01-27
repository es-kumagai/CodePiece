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
import ESTwitter

@objcMembers
class TwitterPreferenceViewController: NSViewController, NotificationObservable {

	var notificationHandlers = Notification.Handlers()
	
	private(set) var waitingHUD:ProgressHUD = ProgressHUD(message: "Please wait...", useActivityIndicator: true)
	private(set) var verifyingHUD:ProgressHUD = ProgressHUD(message: "Verifying...", useActivityIndicator: true)

	@IBOutlet var credentialsVerificationStatusImageView: NSImageView!
	@IBOutlet var credentialsVerificationStatusTextField: NSTextField!
	@IBOutlet var credentialsVerificationButton: NSButton!
	
	@IBOutlet var selectedAccountName: NSTextField!
	
	@IBOutlet var errorReportTextField: NSTextField? {
		
		didSet {
			clearError()
		}
	}
	
	var verifying:Bool = false {
		
		willSet {
			
			willChangeValue(forKey: "canVerify")
			
			if newValue {
				
				verifyingHUD.show()
			}
		}
		
		didSet {
			
			didChangeValue(forKey: "canVerify")
			
			if !verifying {
				
				verifyingHUD.hide()
			}
		}
	}
	
	var hasToken: Bool {

		return NSApp.twitterController.token != nil
	}
	
	var credentialsNotVerified: Bool {

		// FIXME: 🌙 モーダル画面でベリファイしようとすると、メインスレッドで実行しているからか、閉じるまでベリファイ作業が継続されない。
		return !NSApp.twitterController.credentialsVerified
	}
	
	var credentialsVerified: Bool {

		return NSApp.twitterController.credentialsVerified
	}
	
	@IBAction func pushResetAuthorizationButton(_ sender:NSButton) {
	
		self.resetAuthorization()
	}
	
	func resetAuthorization() {

		self.withChangeValue(for: "hasAccount") {

			NSApp.twitterController.resetAuthentication()
		}
	}
			
	func applyAuthorizedStatus() {
		
		self.selectedAccountName.stringValue = NSApp.twitterController.token?.screenName ?? ""
		
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
		
//		observe(notification: TwitterAccountSelectorController.TwitterAccountSelectorDidChangeNotification.self) { [unowned self] notification in
//
//			self.withChangeValue(for: "hasAccount") {
//
//				NSApp.twitterController.account = notification.account
//			}
//
//		}
		
		observe(notification: TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.withChangeValue(for: "credentialsVerified", "credentialsNotVerified")
			self.applyAuthorizedStatus()
		}
		
		observe(notification: TwitterController.AuthorizationStateDidChangeWithErrorNotification.self) { [unowned self] notification in
			
			self.withChangeValue(for: "credentialsVerified", "credentialsNotVerified")
			self.applyAuthorizedStatus()
		}

		verifyCredentials()
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		applyAuthorizedStatus()
	}
}

// MARK: Error Reporting

extension TwitterPreferenceViewController {
	
	func clearError() {
		
		self.reportError("")
	}
	
	func reportError(_ message:String) {
		
		if !message.isEmpty {
			
			NSLog(message)
		}
		
		self.errorReportTextField?.stringValue = message
	}
}

// MARK: Verification

extension TwitterPreferenceViewController {
	
	@IBAction func pushVerifyCredentialsButton(_ sender:NSButton) {

		verifyCredentials()
	}
	
	var canVerify: Bool {
		
		return hasToken && credentialsNotVerified
	}
	
	func verifyCredentials() {

		guard canVerify else {

			return
		}

		NSApp.twitterController.verifyCredentialsIfNeed()
//		self.verifying = NSApp.twitterController.verifyCredentialsIfNeed { result in
//
//			self.verifying = false
//
//			switch result {
//
//			case .success:
//				NSLog("Twitter credentials verified successfully.")
//
//			case .failure(let error):
//				self.showErrorAlert(withTitle: "Failed to verify credentials", message: error.localizedDescription)
//			}
//		}
	}
}

