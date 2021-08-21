//
//  AppDelegate.swift
//  CodePiece-Rev2
//
//  Created by Tomohiro Kumagai on 2020/01/11.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa
import Ocean
import Sky_AppKit

// FIXME: 現在は ATS を無効化しています。OSX 10.11 になったら ATS ありでも動くように調整したいところです。
@NSApplicationMain @objcMembers
class AppDelegate: NSObject, NSApplicationDelegate, NotificationObservable {

	var urlSchemeManager: URLSchemeManager!
	var notificationHandlers = Notification.Handlers()
	
	
	override func awakeFromNib() {
		
		NSLog("Application awoke.")
		
		super.awakeFromNib()

		let schemes: [URLScheme.Type] = [
			
			GistScheme.self,
			SwifterScheme.self,
			CodePieceScheme.self
		]
		
		urlSchemeManager = URLSchemeManager(schemes: schemes)
		NSApplication.readyForUse()
	}

    func applicationDidFinishLaunching(_ aNotification: Notification) {

		NSLog("Application launched.")
		
    }

    func applicationWillTerminate(_ aNotification: Notification) {

		NSLog("Application terminated.")
    }
}

