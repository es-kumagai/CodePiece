//
//  AESAlgorithm.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/29.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import CommonCrypto

struct CryptionAlgorithm : RawRepresentable {
	
	var rawValue: Int
}

extension CryptionAlgorithm {
	
	static let aes = Self(rawValue: kCCAlgorithmAES)
	static let des = Self(rawValue: kCCAlgorithmDES)
	static let threeDes = Self(rawValue: kCCAlgorithm3DES)
	static let cast = Self(rawValue: kCCAlgorithmCAST)
	static let rc4 = Self(rawValue: kCCAlgorithmRC4)
	static let rc2 = Self(rawValue: kCCAlgorithmRC2)
	static let blowfish = Self(rawValue: kCCAlgorithmBlowfish)
}
