//
//  TwitterByOSPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 9/9/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

final class TwitterByOSPreferenceViewController: TwitterPreferenceViewController {
	
	@IBOutlet var accountSelectorController: TwitterAccountSelectorController!
	
	override func resetAuthorization() {
		
		super.resetAuthorization()
		
		updateAccountSelector()
	}
}

// MARK: OS Authentication

extension TwitterByOSPreferenceViewController {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
				
		// In order to just to avoid update account list when user selecting, monitoring notification NSWindowDidBecomeKeyNotification rather than ACAccountStoreDidChangeNotification.
		self.observeNotificationNamed(NSWindowDidBecomeKeyNotification) { [weak self] notification in
			
			if notification.object === self?.view.window {
				
				self!.checkCanAccessToAccountsAndUpdateAccountSelector()
			}
		}
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		updateAccountSelector()
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

	func updateAccountSelector() {
		
		accountSelectorController.updateAccountSelector()
		
		if !accountSelectorController.hasAccount {
			
			self.reportError("No Twitter account found. Please register a twitter account using Account settings.")
		}
	}
}

// MARK: Preferences

extension TwitterByOSPreferenceViewController {
	
	func openSystemPreferences(panel:String) {
		
		// 表示に時間がかかるので、気持ち待ち時間を HUD で紛らわします。
		waitingHUD.show()
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(6 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
			
			self.waitingHUD.hide()
		}
		
		NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: "/System/Library/PreferencePanes/\(panel).prefPane"))
	}

	@IBAction func openAccountsPreferences(sender:NSButton) {
		
		self.openSystemPreferences("InternetAccounts")
	}
	
	@IBAction func openSecurityPreferences(sender:NSButton) {
		
		// TODO: I want to open Security preferences directly.
		self.openSystemPreferences("Security")
	}
}

