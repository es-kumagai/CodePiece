//
//  URLScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

protocol URLScheme {
	
	static var scheme:String { get }
	static var host:String { get }
	
	static func action(url: URL)
}

extension URLScheme {
	
	static func match(url: URL) -> Bool {
		
		return url.scheme == self.scheme && url.host == self.host
	}
}

