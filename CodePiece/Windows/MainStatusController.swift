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

		// FIXME: 😫 runModdal 時（ここ）に新たにモーダルでシートを表示（ストーリーボードから）して、そこで NSAlert を runModal して、閉じると、
		// FIXME: 😫 自作の Ocean.Notification が receive 時に Notification の解放で BAD_ACCESS になってしまう。
//		Authorization.TwitterAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
//			
//			self.twitterAccountNameTextField.stringValue = notification.username ?? none
//		}
//		
//		Authorization.GitHubAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
//			
//			self.githubAccountNameTextField.stringValue = notification.username ?? none
//		}

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "twitterAuthorizationStateDidChangeNotification:", name: Authorization.TwitterAuthorizationStateDidChangeNotification.notificationIdentifier, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "githubAuthorizationStateDidChangeNotification:", name: Authorization.GitHubAuthorizationStateDidChangeNotification.notificationIdentifier, object: nil)
	}
	
	func twitterAuthorizationStateDidChangeNotification(notification:NSNotification) {
		
		let object = notification.object as! Authorization.TwitterAuthorizationStateDidChangeNotification
		
		self.twitterAccountNameTextField.stringValue = object.username ?? none
	}
	
	func githubAuthorizationStateDidChangeNotification(notification:NSNotification) {
		
		let object = notification.object as! Authorization.GitHubAuthorizationStateDidChangeNotification
		
		self.githubAccountNameTextField.stringValue = object.username ?? none
	}
}
