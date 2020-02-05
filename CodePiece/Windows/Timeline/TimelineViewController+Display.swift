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
		
		case updating
		case updated
	}
	
	var displayControlsForUpdating: [NSView?] {
		
		return [self.timelineUpdateIndicator]
	}
	
	var displayControlsForUpdated: [NSView?] {
		
		return [self.timelineRefreshButton]
	}
	
	func updateDisplayControlsVisiblityForState() {
		
        self.updateDisplayControlsVisiblityForState(state: displayControlState)
	}
	
	func updateDisplayControlsVisiblityForState(state: DisplayControlState) {
        
		precondition(Thread.isMainThread)
		
		let controlsForShow: [NSView?]
		let controlsForHide: [NSView?]
		
		switch state {
			
		case .updating:
			timelineUpdateIndicator?.startAnimation(self)
			controlsForShow = displayControlsForUpdating
			controlsForHide = displayControlsForUpdated
			
		case .updated:
			timelineUpdateIndicator?.stopAnimation(self)
			controlsForShow = displayControlsForUpdated
			controlsForHide = displayControlsForUpdating
		}

        controlsForShow.forEach { $0?.isHidden = false }
		controlsForHide.forEach { $0?.isHidden = true }
	}
}
