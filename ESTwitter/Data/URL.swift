//
//  URL.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

public struct URL : RawRepresentable {
	
	public var rawValue: String
	
	public init(rawValue: String) {
		
		self.rawValue = rawValue
	}
}

extension URL : Decodable {
	
	public init(from decoder: Decoder) throws {
		
		rawValue = try decoder.singleValueContainer().decode(String.self)
	}
}

extension URL {
	
	public var url: Foundation.URL? {
		
		return Foundation.URL(string: self.rawValue)
	}
}

extension URL : CustomStringConvertible {
	
	public var description:String {
		
		return self.rawValue
	}
}
