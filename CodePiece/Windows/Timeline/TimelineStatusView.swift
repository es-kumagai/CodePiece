//
//  TimelineStatusView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/08.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
final class TimelineStatusView: NSView {

	@IBOutlet var statusLabel: NSTextField? {
		
		didSet {
			
			statusLabel?.stringValue = ""
			applyForegroundColorToStatusLabel()
		}
	}
	
	enum State {
		
		case OK
		case Error
	}
	
	var state: State = .OK {
		
		didSet {
			
			applyForegroundColorToStatusLabel()
            setNeedsDisplay(frame)
		}
	}
	
	private func applyForegroundColorToStatusLabel() {
		
		statusLabel?.textColor = foregroundColor
	}
	
	var OKMessage: String {
		
		get {
			
			guard state == .OK else {
				
				return ""
			}
			
			return statusLabel?.stringValue ?? ""
		}
		
		set {
			
			state = .OK
			statusLabel?.stringValue = newValue
		}
	}

	var errorMessage: String {
		
		get {
			
			guard state == .Error else {

				return ""
			}

			return statusLabel?.stringValue ?? ""
		}
		
		set {

			guard !newValue.isEmpty else {
				
				return resetMessage()
			}
			
			state = .Error
			statusLabel?.stringValue = newValue
		}
	}
	
	func clearMessage() {
		
		OKMessage = ""
	}
	
	var foregroundColor: NSColor {
		
		switch state {
			
		case .OK:
            return NSColor.windowFrameColor
			
		case .Error:
			return NSColor(red: 0.5, green: 0.2, blue: 0.2, alpha: 1.0)
		}
	}
	
	var backgroundColor: NSColor {
		
		switch state {
			
		case .OK:
            return NSColor.windowBackgroundColor
			
		case .Error:
			return NSColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0)
		}
	}
	
	func resetMessage() {
		
		state = .OK
		statusLabel?.stringValue = ""
	}
	
	override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)

		backgroundColor.set()
		
		dirtyRect.fill()
    }
}
