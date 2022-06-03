//
//  StatusImageViewStatus.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/14
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import AppKit

extension StatusImageView {

	@objc public enum Status : Int {

		case none
		case available
		case partiallyAvailable
		case unavailable
		
		var image: NSImage {
			
			NSImage(self)
		}
	}
}
