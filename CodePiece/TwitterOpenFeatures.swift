//
//  TwitterOpenFeatures.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/11.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import ESTwitter

final class TwitterOpenFeatures : NSObject, AlertDisplayable {
	
	override func awakeFromNib() {
		
		Authorization.TwitterAuthorizationStateDidChangeNotification.observeBy(self) { [unowned self] notification in

			self.withChangeValue("canOpenTwitterHome")
		}		
	}
	
	var canOpenTwitterHome:Bool {
		
		guard NSApp.isReadyForUse else {
			
			return false
		}

		return NSApp.twitterController.credentialsVerified
	}
	
	@IBAction func openTwitterHomeAction(sender:AnyObject) {
		
		self.openTwitterHome()
	}
	
	func openTwitterHome() {
		
		guard let username = NSApp.twitterController.account?.username else {
			
			return self.showErrorAlert("Failed to open Twitter", message: "Twitter user is not set.")
		}
		
		do {
			
			try ESTwitter.Browser.openWithUsername(username)
		}
		catch ESTwitter.Browser.Error.OperationFailure(reason: let reason) {
			
			self.showErrorAlert("Failed to open Twitter", message: reason)
		}
		catch {
			
			self.showErrorAlert("Failed to open Twitter", message: "Unknown Error : \(error)")
		}
	}
}
