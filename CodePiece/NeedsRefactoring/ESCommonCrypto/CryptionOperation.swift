//
//  AESOperation.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/29.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import CommonCrypto

struct CryptionOperation : RawRepresentable {
	
	var rawValue: Int
}

extension CryptionOperation {
	
	static let encrypt = Self(rawValue: kCCEncrypt)
	static let decrypt = Self(rawValue: kCCDecrypt)
}
