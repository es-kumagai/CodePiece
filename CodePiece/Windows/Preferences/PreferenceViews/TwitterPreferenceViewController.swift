//
//  TwitterPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/22.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Sky_AppKit
import Ocean
import Swim
import ESTwitter

@objcMembers
@MainActor
class TwitterPreferenceViewController: NSViewController, NotificationObservable {

	let notificationHandlers = Notification.Handlers()
	
	private(set) var waitingHUD = ProgressHUD(message: "Please wait...", useActivityIndicator: true)
	private(set) var verifyingHUD = ProgressHUD(message: "Verifying...", useActivityIndicator: true)

	@IBOutlet var credentialsVerificationStatusImageView: NSImageView!
	@IBOutlet var credentialsVerificationStatusTextField: NSTextField!
	@IBOutlet var credentialsVerificationButton: NSButton!
	
	@IBOutlet var selectedAccountName: NSTextField!
	
	@IBOutlet var errorReportTextField: NSTextField? {
		
		didSet {
			clearError()
		}
	}
	
	dynamic var verifying: Bool = false {
		
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
	
	dynamic var hasToken: Bool {

		NSApp.twitterController.token != nil
	}
	
	dynamic var credentialsNotVerified: Bool {

		// FIXME: 🌙 モーダル画面でベリファイしようとすると、メインスレッドで実行しているからか、閉じるまでベリファイ作業が継続されない。Concurrency になれば大丈夫かもしれない。
		!NSApp.twitterController.credentialsVerified
	}
	
	dynamic var credentialsVerified: Bool {

		NSApp.twitterController.credentialsVerified
	}
	
	@IBAction func pushResetAuthorizationButton(_ sender:NSButton) {
	
		resetAuthorization()
	}
	
	func resetAuthorization() {

		withChangeValue(for: "hasAccount") {

			Task { @MainActor in
				
				await NSApp.twitterController.resetAuthentication()
			}
		}
	}
			
	func applyAuthorizedStatus() {
		
		selectedAccountName.stringValue = NSApp.twitterController.token?.screenName ?? ""
		
		if credentialsNotVerified {
			
			credentialsVerificationStatusTextField.textColor = .authenticatedWithNoTokenForegroundColor
			credentialsVerificationStatusTextField.stringValue = "Need to verify Credentials"
		}
		else {
			
			credentialsVerificationStatusTextField.textColor = .authenticatedForegroundColor
			credentialsVerificationStatusTextField.stringValue = "Credentials Verified"
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
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		observe(TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			withChangeValue(for: "credentialsVerified", "credentialsNotVerified")
			applyAuthorizedStatus()
		}
		
		observe(TwitterController.AuthorizationStateDidChangeWithErrorNotification.self) { [unowned self] notification in
			
			withChangeValue(for: "credentialsVerified", "credentialsNotVerified")
			applyAuthorizedStatus()
		}

		applyAuthorizedStatus()
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		notificationHandlers.releaseAll()
	}
}

// MARK: Error Reporting

extension TwitterPreferenceViewController {
	
	func clearError() {
		
		reportError("")
	}
	
	func reportError(_ message:String) {
		
		if !message.isEmpty {
			
			Log.error(message)
		}
		
		errorReportTextField?.stringValue = message
	}
}

// MARK: Verification

extension TwitterPreferenceViewController {
	
	@IBAction func pushVerifyCredentialsButton(_ sender:NSButton) {

		Task {
			
			await verifyCredentials()
		}
	}
	
	dynamic var canVerify: Bool {
		
		return hasToken && credentialsNotVerified
	}
	
	func verifyCredentials() async {

		guard canVerify else {

			return
		}

		await NSApp.twitterController.verifyCredentialsIfNeed()
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

