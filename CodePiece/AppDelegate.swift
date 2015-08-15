//
//  AppDelegate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESNotification

// FIXME: ⭐️ 現在は ATS を無効化しています。OSX 10.11 になったら ATS ありでも動くように調整します。

var sns:SNSController!
var captureController:WebCaptureController!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AlertDisplayable {

	var urlSchemeManager:URLSchemeManager!
	
	override func awakeFromNib() {
		
		NSLog("Application awoke.")
		
		super.awakeFromNib()

		NotificationManager.dammingNotifications = true
		
		settings = Settings()
	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {

		NSLog("Application launched.")
		
		NotificationManager.dammingNotifications = false

		GitHubClientInfo = CodePieceClientInfo()
		TwitterClientInfo = CodePieceTwitterClientInfo()

		sns = SNSController()
		captureController = WebCaptureController()

		self.urlSchemeManager = URLSchemeManager()
		
		sns.twitter.verifyCredentialsIfNeed()
	}

	func applicationWillTerminate(aNotification: NSNotification) {

		NSLog("Application terminated.")
	}
}

