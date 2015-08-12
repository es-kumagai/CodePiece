//
//  OAuthScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

final class OAuthScheme : URLScheme {
	
	let scheme = "jp.ez-style.scheme.codepiece"
	let host = "oauth"
	
	func action(url: NSURL) {
		
		Authorization.github.oauth2.handleRedirectURL(url)
	}
}
