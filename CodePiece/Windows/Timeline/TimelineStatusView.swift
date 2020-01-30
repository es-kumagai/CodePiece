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
            return .statusOkTextColor
			
		case .Error:
			return .statusErrorTextColor
		}
	}
	
	var backgroundColor: NSColor {
		
		switch state {
			
		case .OK:
            return .statusOkBackgroundColor
			
		case .Error:
			return .statusErrorBackgroundColor
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
