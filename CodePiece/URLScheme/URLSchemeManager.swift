//
//  URLSchemeManager.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

final class URLSchemeManager {

	let eventManager = NSAppleEventManager.shared()
	let eventClass = AEEventClass(kInternetEventClass)
	let eventID = AEEventID(kAEGetURL)
	
	let schemes: [URLScheme.Type] = [
		
		GistScheme.self,
		SwifterScheme.self,
		CodePieceScheme.self
	]
	
	init() {
		eventManager.setEventHandler(self, andSelector: #selector(URLSchemeManager.handleURLEvent(event:withReply:)), forEventClass: eventClass, andEventID: eventID)
	}
	
	deinit {
		
		eventManager.removeEventHandler(forEventClass: eventClass, andEventID: eventID)
	}
	
	@objc func handleURLEvent(event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
		
		if let url = event.url {
			
			for scheme in schemes where scheme.match(url: url) {

				scheme.action(url: url)
			}
		}
		else {

			NSLog("Invalid URL event=\(event), reply=\(reply). ")
		}
	}
}
