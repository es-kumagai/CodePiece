//
//  MainStatusController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/03.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESNotification

private let none = "----"

final class MainStatusViewController: NSViewController, NotificationObservable {

	var notificationHandlers = NotificationHandlers()
	
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
		
		self.githubAccountNameTextField.stringValue = none
		self.twitterAccountNameTextField.stringValue = none
		
		self.observeNotification(Authorization.TwitterAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.twitterAccountNameTextField.stringValue = notification.username ?? none
			self.twitterAccountStatusImageView.status = notification.isValid ? .Available : .Unavailable
		}
		
		self.observeNotification(Authorization.GitHubAuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.githubAccountNameTextField.stringValue = notification.username ?? none
			self.githubAccountStatusImageView.status = notification.isValid ? .Available : .Unavailable
		}
		
		self.observeNotification(ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] notification in
			
			self.updateReachability()
		}
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
