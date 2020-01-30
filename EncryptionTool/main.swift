//
//  main.swift
//  EncryptionTool
//
//  Created by Tomohiro Kumagai on 2020/01/30.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import Ocean

let text = ProcessInfo.processInfo.arguments[1]

do {

	let data = try aes.encrypto(text, initialVector: initialVector)
	
	
}
catch {

	print("ERROR: \(error)")
	exit(1)
}

exit(0)
