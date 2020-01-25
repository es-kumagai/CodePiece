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
	
	@IBOutlet var githubAccountNameTextField:NSTextField!
	@IBOutlet var twitterAccountNameTextField:NSTextField!
	@IBOutlet var reachabilityTextField:NSTextField!
	@IBOutlet var githubAccountStatusImageView:StatusImageView!
	@IBOutlet var twitterAccountStatusImageView:StatusImageView!
	@IBOutlet var reachabilityStatusImageView:StatusImageView!

	override func awakeFromNib() {

		super.awakeFromNib()
		
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		updateGithubAccountStatus()
		updateTwitterAccountStatus()
		
		self.observe(notification: Authorization.TwitterAuthorizationStateDidChangeNotification.self) { _ in
			
			self.updateTwitterAccountStatus()
		}
		
		self.observe(notification: Authorization.GitHubAuthorizationStateDidChangeNotification.self) { _ in
			
			self.updateGithubAccountStatus()
		}
		
		self.observe(notification: ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] notification in
			
			self.updateReachability()
		}
	}
	
	func updateTwitterAccountStatus() {
	
		let twitterController = NSApp.snsController.twitter
		
		updateTwitterAccountStatusWith(isValid: twitterController.credentialsVerified, username: twitterController.account?.username)
	}
	
	// このメソッドを直接呼ぶと実際と食い違う可能性が出てきてしまうので、設定を直接参照するようにする。
	// そうすると Authorization.TwitterAuthorizationStateDidChangeNotification が細かい情報を持たなくて良くなる可能性があるが、
	// それだと今度は有効状態を判定しにくくなる。NSApp.snsController.twitter に状態の問い合わせメソッドを用意するのが良さそう。
	private func updateTwitterAccountStatusWith(isValid: Bool, username: String?) {
		
		twitterAccountNameTextField.stringValue = username ?? none
		twitterAccountStatusImageView.status = isValid ? .Available : .Unavailable
	}
	
	func updateGithubAccountStatus() {
		
		let githubAccount = NSApp.settings.account
		
		updateGithubAccountStatusWith(isValid: githubAccount.authorizationState == .Authorized, username: githubAccount.username)
	}
	
	// このメソッドを直接呼ぶと実際と食い違う可能性が出てきてしまうので、設定を直接参照するようにする。
	// そうすると Authorization.GitHubAuthorizationStateDidChangeNotification が細かい情報を持たなくて良くなる可能性があるが、
	// それだと今度は有効状態を判定しにくくなる。NSApp.settings.account に状態の問い合わせメソッドを用意するのが良さそう。
	private func updateGithubAccountStatusWith(isValid: Bool, username: String?) {
		
		githubAccountNameTextField.stringValue = username ?? none
		githubAccountStatusImageView.status = isValid ? .Available : .Unavailable
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
	
		updateReachability()
	}
	
	func updateReachability() {
		
		let state = NSApp.reachabilityController.state
		
		self.reachabilityTextField.stringValue = state.description
		self.reachabilityStatusImageView.status = StatusImageView.Status(reachabilityState: state)
	}
}
