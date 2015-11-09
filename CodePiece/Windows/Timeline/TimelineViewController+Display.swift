//
//  TimelineViewController+Display.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/09.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

extension TimelineViewController {
	
	enum DisplayControlState {
		
		case Updating
		case Updated
	}
	
	var displayControlsForUpdating: [NSView?] {
		
		return [self.timelineUpdateIndicator]
	}
	
	var displayControlsForUpdated: [NSView?] {
		
		return [self.timelineRefreshButton]
	}
	
	func updateDisplayControlsForState() {
		
		self.updateDisplayControlsForState(self.displayControlState)
	}
	
	func updateDisplayControlsForState(state: DisplayControlState) {
		
		precondition(NSThread.isMainThread())
		
		let controlsForShow: [NSView?]
		let controlsForHide: [NSView?]
		
		switch state {
			
		case .Updating:
			controlsForShow = self.displayControlsForUpdating
			controlsForHide = self.displayControlsForUpdated
			
		case .Updated:
			controlsForShow = self.displayControlsForUpdated
			controlsForHide = self.displayControlsForUpdating
		}

		controlsForShow.forEach { $0?.hidden = false }
		controlsForHide.forEach { $0?.hidden = true }
	}
}
