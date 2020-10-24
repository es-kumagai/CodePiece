//
//  URL.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

public struct TwitterUrl : RawRepresentable {
	
	public var rawValue: String
	
	public init(rawValue: String) {
		
		self.rawValue = rawValue
	}
}

extension TwitterUrl : Decodable {
	
	public init(from decoder: Decoder) throws {
		
		rawValue = try decoder.singleValueContainer().decode(String.self)
	}
}

extension TwitterUrl {
	
	public var url: URL? {
		
		return URL(string: rawValue)
	}
}

extension TwitterUrl : CustomStringConvertible {
	
	public var description:String {
		
		return rawValue
	}
}
