//
//  Options.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/29.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import CommonCrypto

struct CryptionOption : OptionSet {
	
	var rawValue: Int
}

extension CryptionOption {
	
	static let pkcs7Padding = Self(rawValue: kCCOptionPKCS7Padding)
	static let ecbMode = Self(rawValue: kCCOptionECBMode)
}
