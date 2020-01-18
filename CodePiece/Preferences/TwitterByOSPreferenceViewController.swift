//
//  TwitterByOSPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 9/9/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
final class TwitterByOSPreferenceViewController: TwitterPreferenceViewController {
	
//	@IBOutlet var accountSelectorController: TwitterAccountSelectorController!
	
	override func resetAuthorization() {
		
		super.resetAuthorization()
		
//		updateAccountSelector()
	}
}

// MARK: OS Authentication

extension TwitterByOSPreferenceViewController {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
				
		// In order to just to avoid update account list when user selecting, monitoring notification NSWindowDidBecomeKeyNotification rather than ACAccountStoreDidChangeNotification.
//		self.observe(notificationNamed: NSWindow.didBecomeKeyNotification) { [weak self] notification in
//			
//			if let window = notification.object as? NSWindow, window === self?.view.window {
//				
//				self!.checkCanAccessToAccountsAndUpdateAccountSelector()
//			}
//		}
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
//		updateAccountSelector()
	}
	
//	private func checkCanAccessToAccountsAndUpdateAccountSelector() {
//
//		TwitterController.requestAccessToAccounts { result in
//
//			self.clearError()
//			self.updateAccountSelector()
//
//			switch result {
//
//			case .success:
//				break
//
//			case .failure(let error):
//				NSLog("Access to Twitter account is not allowed. \(error)")
//				self.reportError("Access to Twitter account is not allowed. Please give permission to access Twitter account using Privacy settings.")
//			}
//		}
//	}

//	func updateAccountSelector() {
//
//		accountSelectorController.updateAccountSelector()
//
//		if !accountSelectorController.hasAccount {
//
//			self.reportError("No Twitter account found. Please register a twitter account using Account settings.")
//		}
//	}
}

// MARK: Preferences

extension TwitterByOSPreferenceViewController {
	
	func openSystemPreferences(_ panel: String) {
		
		// 表示に時間がかかるので、気持ち待ち時間を HUD で紛らわします。
		waitingHUD.show()

		DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
			
			self.waitingHUD.hide()
		}
		
		NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/\(panel).prefPane"))
	}

	@IBAction func openAccountsPreferences(_ sender:NSButton) {
		
		self.openSystemPreferences("InternetAccounts")
	}
	
	@IBAction func openSecurityPreferences(_ sender:NSButton) {
		
		// TODO: I want to open Security preferences directly.
		self.openSystemPreferences("Security")
	}
}

