//
//  URLScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

protocol URLScheme {
	
	var scheme:String { get }
	var host:String { get }
	
	func action(url: URL)
}

extension URLScheme {
	
	func match(url: URL) -> Bool {
		
		return url.scheme == self.scheme && url.host == self.host
	}
}

