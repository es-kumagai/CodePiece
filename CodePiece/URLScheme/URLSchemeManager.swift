//
//  URLSchemeManager.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

final class URLSchemeManager {

	let eventManager = NSAppleEventManager.sharedAppleEventManager()
	let eventClass = AEEventClass(kInternetEventClass)
	let eventID = AEEventID(kAEGetURL)
	
	let schemes:[URLScheme] = [ OAuthScheme() ]
	
	init() {
		
		self.eventManager.setEventHandler(self, andSelector: "handleURLEvent:withReply:", forEventClass: self.eventClass, andEventID: self.eventID)
	}
	
	deinit {
		
		self.eventManager.removeEventHandlerForEventClass(self.eventClass, andEventID: self.eventID)
	}
	
	@objc func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
		
		if let url = event.url {
			
			self.schemes.forEach { $0.action(url) }
		}
		else {

			NSLog("Invalid URL event=\(event), reply=\(reply). ")
		}
	}
}