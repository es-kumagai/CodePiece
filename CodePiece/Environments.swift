//
//  Environments.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/25.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

struct Environment {
	
	var debugOnXcodeServer: Bool
    var useKeychain: Bool
	var showWelcomeBoardOnStartup: Bool
	
    init() {
		
		let environments = ProcessInfo.processInfo.environment
		
		#if DEBUG
			debugOnXcodeServer = environments.keys.contains("XCS")
		#else
			debugOnXcodeServer = false
		#endif
		
		if debugOnXcodeServer {

			useKeychain = false
			showWelcomeBoardOnStartup = false
		}
		else {

			useKeychain = true
			showWelcomeBoardOnStartup = true
		}
    }
}
