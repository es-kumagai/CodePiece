//
//  TwitterOpenFeatures.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/11.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESTwitter

final class TwitterOpenFeatures : NSObject, AlertDisplayable {
	
	override func awakeFromNib() {
		
		Authorization.TwitterAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in

			self.withChangeValue("canOpenTwitterHome") {
				
			}
		}		
	}
	
	var canOpenTwitterHome:Bool {
		
		return sns?.twitter.credentialsVerified ?? false
	}
	
	@IBAction func openTwitterHomeAction(sender:AnyObject) {
		
		self.openTwitterHome()
	}
	
	func openTwitterHome() {
		
		guard let username = sns.twitter.account?.username else {
			
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
