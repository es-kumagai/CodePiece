//
//  TwitterOpenFeatures.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/11.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import ESTwitter
import Ocean

@objcMembers
final class TwitterOpenFeatures : NSObject, AlertDisplayable, NotificationObservable {
	
	var notificationHandlers = Notification.Handlers()
	
	override init() {
		
		super.init()
		
		observe(TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in

			withChangeValue(for: "canOpenTwitterHome")
		}		
	}
	
	var canOpenTwitterHome: Bool {
		
		guard NSApp.isReadyForUse else {
			
			return false
		}

		return NSApp.twitterController.readyToUse
	}
	
	@IBAction func openTwitterHomeAction(_ sender:AnyObject) {
		
		openTwitterHome()
	}
	
	func openTwitterHome() {
		
		guard let username = NSApp.twitterController.token?.screenName else {
			
			return showErrorAlert(withTitle: "Failed to open Twitter", message: "Twitter user is not set.")
		}
		
		do {
			
			try ESTwitter.Browser.openWithUsername(username)
		}
		catch ESTwitter.Browser.BrowseError.OperationFailure(reason: let reason) {
			
			showErrorAlert(withTitle: "Failed to open Twitter", message: reason)
		}
		catch {
			
			showErrorAlert(withTitle: "Failed to open Twitter", message: "Unknown Error : \(error)")
		}
	}
}
