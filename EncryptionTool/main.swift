//
//  main.swift
//  EncryptionTool
//
//  Created by Tomohiro Kumagai on 2020/01/30.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import Ocean
import CodePieceSupport

let text = ProcessInfo.processInfo.arguments[1]

do {

	let data = try cipher.encrypto(text, initialVector: nil)
	
	print("Source: \(text)")
	print()
	
	print("Array<Int>:")
	print("[", data.map { String(format: "%02X", $0) }.joined(separator: ", "), "]")
	print()
	
	print("Plist Display Style:")
	print("{length = \(data.count), 0x\(data.map { String(format: "%02X", $0) }.joined())}")
	print()
	
	print("Base64 Encoding:")
	print(data.base64EncodedString())
	print()
	
	print("Decrypted String:")
	print(try! cipher.decrypto(data, initialVector: nil))
}
catch {

	print("ERROR: \(error)")
	exit(1)
}

exit(0)
