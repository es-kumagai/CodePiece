//
//  TimelineStatusView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/08.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter


@objcMembers
final class TimelineStatusView: NSView {

	@IBOutlet var statusLabel: NSTextField? {
		
		didSet {
			
			statusLabel?.stringValue = ""
			applyForegroundColorToStatusLabel()
		}
	}
	
	enum State {
		
		case ok(String)
		case error(PostError)
	}
	
	var state: State = .ok("") {
		
		didSet {
			
			applyForegroundColorToStatusLabel()
            setNeedsDisplay(frame)
			
			statusLabel?.stringValue = message
			
			#if DEBUG
			if case .error = state {
				NSLog("An error occurres when updating timeline: \(message)")
			}
			#endif
		}
	}
	
	private func applyForegroundColorToStatusLabel() {
		
		statusLabel?.textColor = foregroundColor
	}
	
	var message: String {
		
		switch state {
			
		case .ok(let message):
			return message
			
		case .error(.apiError(let error, _)):
			return "\(error)"
			
		case .error(.tweetError(let message)):
			return message
			
		case .error(.parseError(let message, _)):
			return message
			
		case .error(.internalError(let message, _)):
			return message
			
		case .error(.unexpectedError(let error)):
			return "\(error)"
		}
	}
	
	func clearMessage() {
		
		state = .ok("")
	}
		
	var foregroundColor: NSColor {
		
		switch state {
			
		case .ok:
            return .statusOkTextColor
			
		case .error:
			return .statusErrorTextColor
		}
	}
	
	var backgroundColor: NSColor {
		
		switch state {
			
		case .ok:
            return .statusOkBackgroundColor
			
		case .error:
			return .statusErrorBackgroundColor
		}
	}
	
	override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

		backgroundColor.set()
		
		dirtyRect.fill()
    }
}
