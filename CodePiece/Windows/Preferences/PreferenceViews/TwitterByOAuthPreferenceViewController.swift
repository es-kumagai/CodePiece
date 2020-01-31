//
//  TwitterByOAuthPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 9/9/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESProgressHUD

@objcMembers
final class TwitterByOAuthPreferenceViewController : TwitterPreferenceViewController {
	
	private var authenticatingHUD = ProgressHUD(message: "Please authenticate with the launched browser.\n", useActivityIndicator: true)
//	private var authenticatingPinHUD:ProgressHUD = ProgressHUD(message: "Please authentication with PIN code.\n", useActivityIndicator: true)

	@IBOutlet private(set) var viewForStartAuthentication: NSView!
//	@IBOutlet private(set) var viewForEnterPin: NSView!
//
//	@IBOutlet private(set) var pinTextField: NSTextField! {
//
//		didSet {
//
//			pinTextField.delegate = self
//		}
//	}
		
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		observe(notification: TwitterController.AuthorizationStateDidChangeNotification.self) { notification in
			
			NSLog("%@", "Twitter authorization is finished successfully.")
			self.authenticatingHUD.hide()
		}
		
		observe(notification: TwitterController.AuthorizationStateDidChangeWithErrorNotification.self) { [unowned self] notification in

			NSLog("Twitter authorization failure. %@", "\(notification.error)")
			self.authenticatingHUD.hide()
		}
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
//		updatePinInputMode()
		
		
	}
}

extension TwitterByOAuthPreferenceViewController : NSTextFieldDelegate {
	
	func controlTextDidChange(_ obj: Notification) {

//		guard let object = obj.object as? NSTextField, object === self.pinTextField else {
//			
//			return
//		}
//		
//		withChangeValue(for: "canPinEnterButtonPush")
	}
}

// MARK: PIN

extension TwitterByOAuthPreferenceViewController {
	
	@IBAction func doAuthentication(_ sender:NSButton) {
		
		authenticatingHUD.show()
		
		NSApp.twitterController.authorize()

//		Authorization.authorizationWithTwitter { result in
//
//			self.authenticatingHUD.hide()
//
//			switch result {
//
//			case .Created:
//				NSLog("%@", "Twitter authorization is finished successfully.")
//
//			case .Failed(let error):
//				self.showErrorAlert(withTitle: "Failed to authentication", message: error.description)
//
////			case .PinRequired:
////				self.enteringPinInputMode()
//			}
//		}
	}
	
//	@IBAction func doEnterPin(_ sender: NSButton) {
//
//		#warning("いったん、処理を無効化してあります。")
//		NSLog("%@", "いったん、処理を無効化してあります。")
//		authenticatingPinHUD.show()
//
//		Authorization.authorizationWithTwitter(pin: pinTextField.stringValue) { result in
//
//			self.authenticatingPinHUD.hide()
//
//			switch result {
//
//			case .Created:
//				self.exitPinInputMode()
//				self.dismiss(self)
//
//			case .Failed(let message):
//				self.showErrorAlert(withTitle: "Failed to authentication", message: message.description)
//
//			case .PinRequired:
//				self.showErrorAlert(withTitle: "Failed to authentication", message: "Unexpected Process (PIN Required)")
//			}
//		}
//	}
	
//	var canPinEnterButtonPush: Bool {
//
//		guard let pinTextField = self.pinTextField else {
//
//			return false
//		}
//
//		return !pinTextField.stringValue.isEmpty
//	}
	
//	func updatePinInputMode() {
//
//		switch Authorization.isTwitterPinRequesting {
//
//		case true:
//			enteringPinInputMode()
//
//		case false:
//			exitPinInputMode()
//		}
//	}
	
//	func enteringPinInputMode() {
//
//		self.viewForStartAuthentication?.isHidden = true
//		self.viewForEnterPin?.isHidden = false
//	}
//
//	func exitPinInputMode() {
//
//		self.viewForStartAuthentication?.isHidden = false
//		self.viewForEnterPin?.isHidden = true
//
//		self.pinTextField?.stringValue = ""
//	}
}
