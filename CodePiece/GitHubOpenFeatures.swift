//
//  GitHubOpenFeatures.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/11.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

final class GitHubOpenFeatures : NSObject, AlertDisplayable {

	override func awakeFromNib() {
		
		Authorization.GitHubAuthorizationStateDidChangeNotification.observeBy(self) { owner, notification in
			
			self.withChangeValue("canOpenGitHubHome") {
				
			}
		}
	}
	
	var canOpenGitHubHome:Bool {
		
		return settings?.account.authorizationState.isValid ?? false
	}
	
	@IBAction func openGitHubHomeAction(sender:AnyObject) {
	
		self.openGitHubHome()
	}
	
	func openGitHubHome() {
		
		guard let username = settings.account.username else {
			
			return self.showErrorAlert("Failed to open GitHub", message: "GitHub user is not set.")
		}
		
		let urlString = "https://GitHub.com/\(username)"
		
		guard let url = NSURL(string: urlString) else {
			
			return self.showErrorAlert("Failed to open GitHub", message: "Invalid URL '\(urlString)'.")
		}
		
		NSWorkspace.sharedWorkspace().openURL(url).ifFalse {
			
			self.showErrorAlert("Failed to open GitHub", message: "URL '\(url)' cannot open.")
		}
	}
}
