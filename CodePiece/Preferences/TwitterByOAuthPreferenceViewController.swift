//
//  TwitterByOAuthPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 9/9/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESProgressHUD

final class TwitterByOAuthPreferenceViewController : TwitterPreferenceViewController {
	
	private var authenticatingHUD:ProgressHUD = ProgressHUD(message: "Please authentication with in browser which will be opened.\n", useActivityIndicator: true)
	private var authenticatingPinHUD:ProgressHUD = ProgressHUD(message: "Please authentication with PIN code.\n", useActivityIndicator: true)

	@IBOutlet private(set) var viewForStartAuthentication: NSView!
	@IBOutlet private(set) var viewForEnterPin: NSView!
	
	@IBOutlet private(set) var pinTextField: NSTextField!
		
	override func viewDidLoad() {
		
		super.viewDidLoad()		
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		updatePinInputMode()
	}
	
	override func controlTextDidChange(obj: NSNotification) {
		
		guard obj.object === self.pinTextField else {
			
			return
		}
		
		withChangeValue("canPinEnterButtonPush")
	}
}

// MARK: PIN

extension TwitterByOAuthPreferenceViewController {
	
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
	
	func updatePinInputMode() {
		
		switch Authorization.isTwitterPinRequesting {
			
		case true:
			enteringPinInputMode()
			
		case false:
			exitPinInputMode()
		}
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
}
