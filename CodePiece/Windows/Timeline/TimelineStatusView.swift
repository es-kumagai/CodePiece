//
//  TimelineStatusView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/08.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class TimelineStatusView: NSView {

	@IBOutlet var statusLabel: NSTextField? {
		
		didSet {
			
			self.statusLabel?.stringValue = ""
			self.applyForegroundColorToStatusLabel()
		}
	}
	
	enum State {
		
		case OK
		case Error
	}
	
	var state: State = .OK {
		
		didSet {
			
			self.applyForegroundColorToStatusLabel()
			self.setNeedsDisplayInRect(self.frame)
		}
	}
	
	private func applyForegroundColorToStatusLabel() {
		
		self.statusLabel?.textColor = self.foregroundColor
	}
	
	var OKMessage: String {
		
		get {
			
			guard self.state == .OK else {
				
				return ""
			}
			
			return self.statusLabel?.stringValue ?? ""
		}
		
		set {
			
			self.state = .OK
			self.statusLabel?.stringValue = newValue
		}
	}

	var errorMessage: String {
		
		get {
			
			guard self.state == .Error else {

				return ""
			}

			return self.statusLabel?.stringValue ?? ""
		}
		
		set {

			guard !newValue.isEmpty else {
				
				return resetMessage()
			}
			
			self.state = .Error
			self.statusLabel?.stringValue = newValue
		}
	}
	
	func clearMessage() {
		
		self.OKMessage = ""
	}
	
	var foregroundColor: NSColor {
		
		switch state {
			
		case .OK:
			return NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
			
		case .Error:
			return NSColor(red: 0.5, green: 0.2, blue: 0.2, alpha: 1.0)
		}
	}
	
	var backgroundColor: NSColor {
		
		switch state {
			
		case .OK:
			return NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
			
		case .Error:
			return NSColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0)
		}
	}
	
	func resetMessage() {
		
		self.state = .OK
		self.statusLabel?.stringValue = ""
	}
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

		self.backgroundColor.set()
		
		NSRectFill(dirtyRect)
    }
}
