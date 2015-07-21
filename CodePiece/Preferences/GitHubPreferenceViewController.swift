//
//  GitHubPreferenceViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean

class GitHubPreferenceViewController: NSViewController {

	@IBOutlet weak var authorizedStatusImageView:NSImageView!
	@IBOutlet weak var authorizedStatusTextField:NSTextField!
	@IBOutlet weak var authorizationButton:NSButton!
	@IBOutlet weak var resetButton:NSButton!
	
//	@IBAction func doAuthentication(sender:NSButton) {
//	
//	}
	
	@IBAction func doReset(sender:NSButton) {
		
		guard let id = settings.account.id else {
			
			settings.resetGitHubAccount()
			return
		}
		
		Authorization.resetAuthorizationOfGitHub(id)
	}
	
	var authorizationState:AuthorizationState {
		
		return settings.account.authorizationState
	}
	
	func applyAuthorizedStatus() {
		
		switch self.authorizationState {
			
		case .Authorized:

			self.authorizedStatusTextField.textColor = SystemColor.TextForAuthenticated.color
			self.authorizedStatusTextField.stringValue = "Authenticated"
			
			self.authorizationButton.enabled = false
			self.resetButton.enabled = true
		
		case .AuthorizedWithNoToken:
			
			self.authorizedStatusTextField.textColor = SystemColor.TextForAuthenticatedWithNoTalken.color
			self.authorizedStatusTextField.stringValue = "Re-Authentication may be needed"
			
			self.authorizationButton.enabled = true
			self.resetButton.enabled = false
			
			
		case .NotAuthorized:
			
			self.authorizedStatusTextField.textColor = SystemColor.TextForNotAuthenticated.color
			self.authorizedStatusTextField.stringValue = "Not authenticated yet"
			
			self.authorizationButton.enabled = true
			self.resetButton.enabled = false
		}
	}
	
    override func viewDidLoad() {

		super.viewDidLoad()
		
		self.applyAuthorizedStatus()

    }
	
	override func viewWillAppear() {
	
		super.viewWillAppear()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "authorizationStateDidChangeNotification:", name: Authorization.AuthorizationStateDidChangeNotification.notificationIdentifier, object: nil)
		
		// FIXME: 😫 runModdal 時（ここ）に新たにモーダルでシートを表示（ストーリーボードから）して、そこで NSAlert を runModal して、閉じると、
		// FIXME: 😫 自作の Ocean.Notification が receive 時に Notification の解放で BAD_ACCESS になってしまう。
		// FIXME: 😫 もしかして、メインスレッドがブロックされていて、そこへハンドラ呼び出しをかけたりしている？ または weak の解放処理がブロックされてしまっているのか。
//		Authorization.AuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
//
//			NSLog("Detect authorization state changed.")
//			
//			self.applyAuthorizedStatus()
//		}

	}
	
	override func viewWillDisappear() {
		
		NSNotificationCenter.defaultCenter().removeObserver(self, name: Authorization.AuthorizationStateDidChangeNotification.notificationIdentifier, object: nil)
		
		super.viewWillDisappear()
	}

	func authorizationStateDidChangeNotification(notification:NSNotification) {
		
		NSLog("Detect authorization state changed.")

			self.applyAuthorizedStatus()
	}
}
