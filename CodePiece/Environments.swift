//
//  Environments.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/25.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

struct Environment {
	
	var debugOnXcodeServer:Bool
    var useKeychain:Bool
	var showWelcomeBoardOnStartup:Bool
	
    init() {
		
		let environments = NSProcessInfo.processInfo().environment
		
		#if DEBUG
			self.debugOnXcodeServer = environments.keys.contains("XCS")
		#else
			self.debugOnXcodeServer = false
		#endif
		
		if self.debugOnXcodeServer {

			self.useKeychain = false
			self.showWelcomeBoardOnStartup = false
		}
		else {

			self.useKeychain = true
			self.showWelcomeBoardOnStartup = true
		}
    }
}
