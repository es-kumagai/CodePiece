//
//  CryptionContextSize.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/29.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import CommonCrypto

struct CryptionContextSize : RawRepresentable {
	
	var rawValue: Int
}

extension CryptionContextSize {
	
	static let aes128 = Self(rawValue: kCCContextSizeAES128)
	static let des = Self(rawValue: kCCContextSizeDES)
	static let threeDes = Self(rawValue: kCCContextSize3DES)
	static let cast = Self(rawValue: kCCContextSizeCAST)
	static let rc4 = Self(rawValue: kCCContextSizeRC4)
}
