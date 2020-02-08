//
//  MainStatusController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/03.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean

private let none = "----"

@objcMembers
final class MainStatusViewController: NSViewController, NotificationObservable {

	var notificationHandlers = Notification.Handlers()
	
	@IBOutlet var gistAccountNameTextField:NSTextField!
	@IBOutlet var twitterAccountNameTextField:NSTextField!
	@IBOutlet var reachabilityTextField:NSTextField!
	@IBOutlet var gistAccountStatusImageView:StatusImageView!
	@IBOutlet var twitterAccountStatusImageView:StatusImageView!
	@IBOutlet var reachabilityStatusImageView:StatusImageView!

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		updateGistAccountStatus()
		updateTwitterAccountStatus()
	}
	
	func updateTwitterAccountStatus() {
	
		let twitterController = NSApp.snsController.twitter
		
		updateTwitterAccountStatusWith(isValid: twitterController.readyToUse, username: twitterController.token?.screenName)
	}
	
	// FIXME: このメソッドを直接呼ぶと実際と食い違う可能性が出てきてしまうので、設定を直接参照するようにする。
	// そうすると Authorization.TwitterAuthorizationStateDidChangeNotification が細かい情報を持たなくて良くなる可能性があるが、
	// それだと今度は有効状態を判定しにくくなる。NSApp.snsController.twitter に状態の問い合わせメソッドを用意するのが良さそう。
	private func updateTwitterAccountStatusWith(isValid: Bool, username: String?) {
		
		twitterAccountNameTextField.stringValue = username ?? none
		twitterAccountStatusImageView.status = isValid ? .available : .unavailable
	}
	
	func updateGistAccountStatus() {
		
		let gistAccount = NSApp.settings.account
		
		updateGistAccountStatusWith(isValid: gistAccount.authorizationState == .authorized, username: gistAccount.username)
	}
	
	// このメソッドを直接呼ぶと実際と食い違う可能性が出てきてしまうので、設定を直接参照するようにする。
	// そうすると Authorization.GistAuthorizationStateDidChangeNotification が細かい情報を持たなくて良くなる可能性があるが、
	// それだと今度は有効状態を判定しにくくなる。NSApp.settings.account に状態の問い合わせメソッドを用意するのが良さそう。
	private func updateGistAccountStatusWith(isValid: Bool, username: String?) {
		
		gistAccountNameTextField.stringValue = username ?? none
		gistAccountStatusImageView.status = isValid ? .available : .unavailable
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
			
		observe(TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] _ in
			
			self.updateTwitterAccountStatus()
		}
		
		observe(Authorization.GistAuthorizationStateDidChangeNotification.self) { [unowned self] _ in
			
			self.updateGistAccountStatus()
		}
		
		observe(ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] _ in
			
			self.updateReachability()
		}

		updateReachability()
	}
	
	override func viewWillDisappear() {
		
		super.viewWillDisappear()
		
		notificationHandlers.releaseAll()
	}
	
	func updateReachability() {
		
		let state = NSApp.reachabilityController.state
		
		self.reachabilityTextField.stringValue = state.description
		self.reachabilityStatusImageView.status = StatusImageView.Status(reachabilityState: state)
	}
}
