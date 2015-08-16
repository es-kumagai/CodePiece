//
//  MainStatusController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/03.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

private let none = "----"

final class MainStatusController: NSObject {

	@IBOutlet var githubAccountNameTextField:NSTextField!
	@IBOutlet var twitterAccountNameTextField:NSTextField!
	@IBOutlet var githubAccountStatusImageView:StatusImageView!
	@IBOutlet var twitterAccountStatusImageView:StatusImageView!

	override func awakeFromNib() {

		self.githubAccountNameTextField.stringValue = none
		self.twitterAccountNameTextField.stringValue = none

		Authorization.TwitterAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
			
			self.twitterAccountNameTextField.stringValue = notification.username ?? none
			self.twitterAccountStatusImageView.status = notification.isValid ? .Green : .Red
		}
		
		Authorization.GitHubAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
			
			self.githubAccountNameTextField.stringValue = notification.username ?? none
			self.githubAccountStatusImageView.status = notification.isValid ? .Green : .Red
		}
	}
}
