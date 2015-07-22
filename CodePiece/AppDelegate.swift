//
//  AppDelegate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

var sns:SNSController!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AlertDisplayable {

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		GitHubClientInfo = CodePieceClientInfo()
		TwitterClientInfo = CodePieceTwitterClientInfo()

		sns = SNSController()

		sns.twitter.verifyCredentialsIfNeed { result in
			
			switch result {
				
			case .Success:
				NSLog("Twitter credentials verified successfully.")
				
			case .Failure(let error):
				self.showErrorAlert("Failed to verify credentials", message: String(error))
			}
		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

