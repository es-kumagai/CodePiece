//
//  AppDelegate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

// FIXME: ⭐️ 現在は ATS を無効化しています。OSX 10.11 になったら ATS ありでも動くように調整します。

var sns:SNSController!
var captureController:WebCaptureController!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AlertDisplayable {

	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		GitHubClientInfo = CodePieceClientInfo()
		TwitterClientInfo = CodePieceTwitterClientInfo()

		sns = SNSController()
		captureController = WebCaptureController()

		sns.twitter.verifyCredentialsIfNeed { result in
			
			switch result {
				
			case .Success:
				NSLog("Twitter credentials verified successfully. (\(sns.twitter.username))")
				
			case .Failure(let error):
				self.showErrorAlert("Failed to verify credentials", message: "\(error) (\(sns.twitter.username))")
			}
		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

