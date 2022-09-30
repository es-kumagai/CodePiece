//
//  LogViewController.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/09/30
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import SwiftUI

@objcMembers
@MainActor
final class LogViewController : NSHostingController<LogView> {

	convenience init(size: NSSize) {
		
		self.init(rootView: LogView(size: size))
	}
}
