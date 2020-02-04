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
	
	func setMessage(with error: PostError) {
		
		var description: (kind: String, message: String) {
			
			switch error {
				
			case .apiError(let error, _):
				return ("API Error", "\(error)")
				
			case .tweetError(let message):
				return ("Tweet Error", message)
				
			case .parseError(let message, _):
				return ("Parse Error", message)
				
			case .internalError(let message, _):
				return ("Internal Error", message)
				
			case .unexpectedError(let error):
				return ("Unexpected Error", "\(error)")
			}
		}
		
		DebugTime.print("An error occurres when updating timeline (\(description.kind)): \(description.message)")
		
		errorMessage = description.message
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
