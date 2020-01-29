//
//  AES.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/29.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import CommonCrypto

class AES {

	static let initialVectorSize = 128
	
	private(set) var sharedKey: Data
	
	init?(sharedKey key: String) {
	
		guard let key = key.data(using: .utf8) else {
			
			return nil
		}
		
		sharedKey = key
	}
	
	func encrypto(_ text: String, initialVector iv: String? = nil) throws -> String {
		
		guard let iv = iv ?? AES.randomInitialValue(), iv.count == AES.initialVectorSize else {
			
			throw EncryptionError.invalidArgument(message: "Invalid initial vector size passed as an argument.")
		}
		
		guard let text = text.data(using: .utf8) else {
			
			throw EncryptionError.invalidArgument(message: "Invalid text passed as an argument.")
		}
		
		let cryptedDataLength = Int(ceil(Double(text.count) / Double(CryptionBlockSize.aes128.rawValue)))
		let cryptedData = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: cryptedDataLength + 1)
		
		CCCrypt(
			CryptionOperation.encrypt.rawValue,
			CryptionAlgorithm.aes,
			CryptionOption.pkcs7Padding,
			<#T##key: UnsafeRawPointer!##UnsafeRawPointer!#>, <#T##keyLength: Int##Int#>, <#T##iv: UnsafeRawPointer!##UnsafeRawPointer!#>, <#T##dataIn: UnsafeRawPointer!##UnsafeRawPointer!#>, <#T##dataInLength: Int##Int#>, <#T##dataOut: UnsafeMutableRawPointer!##UnsafeMutableRawPointer!#>, <#T##dataOutAvailable: Int##Int#>, <#T##dataOutMoved: UnsafeMutablePointer<Int>!##UnsafeMutablePointer<Int>!#>)
	}
	
	func decrypto(_ text: String) throws -> String {
		
	}
}

extension AES {
	
	enum EncryptionError : Error {
	
		case invalidArgument(message: String)
	}
	
	enum DecryptionError : Error {
		
		case invalidArgument(message: String)
	}
}

extension AES {
	
	static func randomInitialValue() -> String? {
	
		let dataBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: initialVectorSize)
		
		defer {
			
			dataBuffer.deallocate()
		}
		
		if CCRandomGenerateBytes(dataBuffer.baseAddress, initialVectorSize) == kCCSuccess {
			
			let data = Data(buffer: dataBuffer)
			
			return String(data: data, encoding: .utf8)
		}
		else {

			return nil
		}
	}
}
