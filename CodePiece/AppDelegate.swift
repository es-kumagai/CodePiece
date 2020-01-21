//
//  AppDelegate.swift
//  CodePiece-Rev2
//
//  Created by Tomohiro Kumagai on 2020/01/11.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import Ocean

// FIXME: ⭐️ 現在は ATS を無効化しています。OSX 10.11 になったら ATS ありでも動くように調整します。

@NSApplicationMain @objcMembers
class AppDelegate: NSObject, NSApplicationDelegate, AlertDisplayable {

	var urlSchemeManager: URLSchemeManager!
	
	override func awakeFromNib() {
		
		NSLog("Application awoke.")
		
		super.awakeFromNib()

		#warning("通知を堰き止めるのは乱暴なので、それ以外の方法で適切に制御できるようにします。")
//		NotificationManager.dammingNotifications = true

		NSApplication.readyForUse()
	}

    func applicationDidFinishLaunching(_ aNotification: Notification) {

		NSLog("Application launched.")
		
		#warning("通知を堰き止めるのは乱暴なので、それ以外の方法で適切に制御できるようにします。")
//		NotificationManager.dammingNotifications = false
		
		self.urlSchemeManager = URLSchemeManager()
		
//		NSApp.twitterController.verifyCredentialsIfNeed()
    }

    func applicationWillTerminate(_ aNotification: Notification) {

		NSLog("Application terminated.")
    }


}

