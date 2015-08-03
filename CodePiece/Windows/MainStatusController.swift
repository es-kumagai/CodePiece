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

	override func awakeFromNib() {

		self.githubAccountNameTextField.stringValue = none
		self.twitterAccountNameTextField.stringValue = none
		
		Authorization.TwitterAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
			
			self.twitterAccountNameTextField.stringValue = notification.username ?? none
		}
		
		Authorization.GitHubAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
			
			self.githubAccountNameTextField.stringValue = notification.username ?? none
		}
	}
}
