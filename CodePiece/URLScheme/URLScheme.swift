//
//  URLScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

protocol URLScheme {
	
	static var scheme: String { get }
	static var host: String { get }
	
	static func action(url: URL)
}

extension URLScheme {
	
	static func matches(_ url: URL) -> Bool {
		
		url.scheme == scheme && url.host == host
	}
}
