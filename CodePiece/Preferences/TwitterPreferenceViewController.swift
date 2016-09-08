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
import ESNotification

protocol TwitterPreferenceAuthenticationByOAuth : AnyObject {
	
	var viewForStartAuthentication: NSView! { get }
	var viewForEnterPin: NSView! { get }
	
	var pinTextField: NSTextField! { get }
	var canPinEnterButtonPush: Bool { get }
	
	func doAuthentication(sender:NSButton)
	func doEnterPin(sender:NSButton)
	
	func enteringPinInputMode()
	func exitPinInputMode()
}

protocol TwitterPreferenceAuthenticationByOS : AnyObject {

	var accountSelectorController:TwitterAccountSelectorController? { get }
	
	func pushVerifyCredentialsButton(sender:NSButton)

	func openAccountsPreferences(sender:NSButton)
	func openSecurityPreferences(sender:NSButton)
}

final class TwitterPreferenceViewController: NSViewController, NotificationObservable {

	var notificationHandlers = NotificationHandlers()
	
	private var authenticatingHUD:ProgressHUD = ProgressHUD(message: "Please authentication with in browser which will be opened.\n", useActivityIndicator: true)
	private var authenticatingPinHUD:ProgressHUD = ProgressHUD(message: "Please authentication with PIN code.\n", useActivityIndicator: true)
	private var verifyingHUD:ProgressHUD = ProgressHUD(message: "Verifying...", useActivityIndicator: true)
	private var waitingHUD:ProgressHUD = ProgressHUD(message: "Please wait...", useActivityIndicator: true)

	@IBOutlet var credentialsVerificationStatusImageView:NSImageView!
	@IBOutlet var credentialsVerificationStatusTextField:NSTextField!
	@IBOutlet var credentialsVerificationButton:NSButton!
	@IBOutlet var selectedAccountName:NSTextField!
	
	@IBOutlet var errorReportTextField:NSTextField? {
		
		didSet {
			
			self.clearError()
		}
	}
	
	@IBOutlet var accountSelectorController:TwitterAccountSelectorController?
	
	@IBOutlet private(set) var viewForStartAuthentication: NSView!
	@IBOutlet private(set) var viewForEnterPin: NSView!
	
	@IBOutlet private(set) var pinTextField: NSTextField!
	
	var canVerify:Bool {
	
		return !self.verifying && self.hasAccount && self.credentialsNotVerified
	}
	
	var verifying:Bool = false {
		
		willSet {
		
			self.willChangeValueForKey("canVerify")
			
			if newValue {
				
				self.verifyingHUD.show()
			}
		}
		
		didSet {
			
			self.didChangeValueForKey("canVerify")
			
			if !self.verifying {
				
				self.verifyingHUD.hide()
			}
		}
	}
	
	var hasAccount:Bool {
	
		return NSApp.twitterController.account != nil
	}
	
	var credentialsNotVerified:Bool {
	
		// FIXME: 🌙 モーダル画面でベリファイしようとすると、メインスレッドで実行しているからか、閉じるまでベリファイ作業が継続されない。
		return !NSApp.twitterController.credentialsVerified
	}
	
	var credentialsVerified:Bool {
		
		return NSApp.twitterController.credentialsVerified
	}
	
	@IBAction func pushResetAuthorizationButton(sender:NSButton) {
	
		self.resetAuthorization()
	}
	
	func resetAuthorization() {

		self.withChangeValue("hasAccount") {

			NSApp.twitterController.account = nil
			self.updateAccountSelector()
		}
	}
	
	func verifyCredentials() {
		
		guard self.canVerify else {
			
			return
		}
		
		self.verifying = NSApp.twitterController.verifyCredentialsIfNeed { result in
			
			self.verifying = false
			
			switch result {
				
			case .Success:
				NSLog("Twitter credentials verified successfully.")
				
			case .Failure(let error):
				self.showErrorAlert("Failed to verify credentials", message: error.localizedDescription)
			}
		}
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
		
		self.selectedAccountName.stringValue = NSApp.twitterController.effectiveUserInfo?.username ?? ""
		
		if self.credentialsNotVerified {
			
			self.credentialsVerificationStatusTextField.textColor = SystemColor.TextForAuthenticatedWithNoTalken.color
			self.credentialsVerificationStatusTextField.stringValue = "Need to verify Credentials"
		}
		else {
			
			self.credentialsVerificationStatusTextField.textColor = SystemColor.TextForAuthenticated.color
			self.credentialsVerificationStatusTextField.stringValue = "Credentials Verified"
		}
	}
	
	private func checkCanAccessToAccountsAndUpdateAccountSelector() {
		
		TwitterController.requestAccessToAccounts { result in
			
			self.clearError()
			self.updateAccountSelector()
			
			switch result {
				
			case .Success:
				break
				
			case .Failure(let error):
				NSLog("Access to Twitter account is not allowed. \(error)")
				self.reportError("Access to Twitter account is not allowed. Please give permission to access Twitter account using Privacy settings.")
			}
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.observeNotification(TwitterAccountSelectorController.TwitterAccountSelectorDidChangeNotification.self) { [unowned self] notification in
			
			self.withChangeValue("hasAccount") {
				
				NSApp.twitterController.account = notification.account
			}

			self.verifyCredentials()
		}
		
		self.observeNotification(Authorization.TwitterAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.withChangeValue("credentialsVerified", "credentialsNotVerified")
			self.applyAuthorizedStatus()
		}
		
		// In order to just to avoid update account list when user selecting, monitoring notification NSWindowDidBecomeKeyNotification rather than ACAccountStoreDidChangeNotification.
		self.observeNotificationNamed(NSWindowDidBecomeKeyNotification) { [weak self] notification in
			
			if notification.object === self?.view.window {
			
				self!.checkCanAccessToAccountsAndUpdateAccountSelector()
			}
		}
    }
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		self.updateAccountSelector()
		self.exitPinInputMode()
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

extension TwitterPreferenceViewController : TwitterPreferenceAuthenticationByOAuth, NSTextFieldDelegate {
	
	@IBAction func doAuthentication(sender:NSButton) {
		
		self.authenticatingHUD.show()
		
		Authorization.authorizationWithTwitter { result in
			
			self.authenticatingHUD.hide()
			
			switch result {
				
			case .Created:
				self.showErrorAlert("Failed to authentication", message: "Unexpected Process (PIN is not entered)")
				
			case .Failed(let error):
				self.showErrorAlert("Failed to authentication", message: error.description)
				
			case .PinRequired:
				self.enteringPinInputMode()
			}
		}
	}
	
	@IBAction func doEnterPin(sender: NSButton) {
		
		authenticatingPinHUD.show()
		
		Authorization.authorizationWithTwitter(pin: pinTextField.stringValue) { result in
			
			self.authenticatingPinHUD.hide()
			
			switch result {
				
			case .Created:
				self.exitPinInputMode()
				self.dismissController(self)
				
			case .Failed(let message):
				self.showErrorAlert("Failed to authentication", message: message.description)
				
			case .PinRequired:
				self.showErrorAlert("Failed to authentication", message: "Unexpected Process (PIN Required)")
			}
		}
	}
	
	var canPinEnterButtonPush: Bool {
	
		guard let pinTextField = self.pinTextField else {
			
			return false
		}
		
		return pinTextField.stringValue.isExists
	}
	
	func enteringPinInputMode() {

		self.viewForStartAuthentication?.hidden = true
		self.viewForEnterPin?.hidden = false
	}
	
	func exitPinInputMode() {
		
		self.viewForStartAuthentication?.hidden = false
		self.viewForEnterPin?.hidden = true
		
		self.pinTextField?.stringValue = ""
	}
	
	override func controlTextDidChange(obj: NSNotification) {
		
		guard obj.object === self.pinTextField else {
			
			return
		}
		
		withChangeValue("canPinEnterButtonPush")
	}
}

extension TwitterPreferenceViewController : TwitterPreferenceAuthenticationByOS {
	
	@IBAction func openAccountsPreferences(sender:NSButton) {
		
		self.openSystemPreferences("InternetAccounts")
	}
	
	@IBAction func openSecurityPreferences(sender:NSButton) {
		
		// TODO: I want to open Security preferences directly.
		self.openSystemPreferences("Security")
	}
	
	func updateAccountSelector() {
		
		guard let accountSelectorController = self.accountSelectorController else {
			
			return
		}
		
		accountSelectorController.updateAccountSelector()
		
		if !accountSelectorController.hasAccount {
			
			self.reportError("No Twitter account found. Please register a twitter account using Account settings.")
		}
	}
	
	@IBAction func pushVerifyCredentialsButton(sender:NSButton) {
		
		self.verifyCredentials()
	}
}
