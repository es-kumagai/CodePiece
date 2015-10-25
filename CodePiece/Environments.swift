//
//  Environments.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/25.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

struct Environment {
    
    var useKeychain:Bool
	var showWelcomeBoardOnStartup:Bool
    
    init() {
        
        #if XCS
			self.useKeychain = false
			self.showWelcomeBoardOnStartup = false
        #else
			self.useKeychain = true
			self.showWelcomeBoardOnStartup = true
        #endif
    }
}
