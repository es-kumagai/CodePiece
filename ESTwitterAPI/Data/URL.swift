//
//  URL.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct URL : RawRepresentable {
	
	public var rawValue:String
	
	public init(rawValue: String) {
		
		self.rawValue = rawValue
	}
}

extension URL : Decodable {
	
	public static func decode(e: Extractor) throws -> URL {
		
		return try URL(rawValue: String.decode(e))
	}
}

extension URL {
	
	public var url:NSURL? {
		
		return NSURL(string: self.rawValue)
	}
}

extension URL : CustomStringConvertible {
	
	public var description:String {
		
		return self.rawValue
	}
}
