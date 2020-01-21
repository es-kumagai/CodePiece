//
//  OAuthScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

final class SwifterScheme : URLScheme {
	
	let scheme = "jp.ez-net.scheme.codepiece.authentication"
	let host = "twitter"
	
	func action(url: URL) {
		
		type(of: Authorization.twitter.swifter).handleOpenURL(url)
	}
}
