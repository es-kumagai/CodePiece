//
//  CryptionKeySize.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/29.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import CommonCrypto

struct CryptionKeySize : RawRepresentable {
	
	var rawValue: Int
}

extension CryptionKeySize {
	
	static let aes128 = Self(rawValue: kCCKeySizeAES128)
	static let aes192 = Self(rawValue: kCCKeySizeAES192)
	static let aes256 = Self(rawValue: kCCKeySizeAES256)
	static let des = Self(rawValue: kCCKeySizeDES)
	static let threeDes = Self(rawValue: kCCKeySize3DES)
	static let minCast = Self(rawValue: kCCKeySizeMinCAST)
	static let maxCast = Self(rawValue: kCCKeySizeMaxCAST)
	static let minRc4 = Self(rawValue: kCCKeySizeMinRC4)
	static let maxRc4 = Self(rawValue: kCCKeySizeMaxRC4)
	static let minRc2 = Self(rawValue: kCCKeySizeMinRC2)
	static let maxRc2 = Self(rawValue: kCCKeySizeMaxRC2)
	static let minBlowfish = Self(rawValue: kCCKeySizeMinBlowfish)
	static let maxBlowfish = Self(rawValue: kCCKeySizeMaxBlowfish)
}
