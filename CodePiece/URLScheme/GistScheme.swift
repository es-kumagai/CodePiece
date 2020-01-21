//
//  GistScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

final class GistScheme : URLScheme {
	
	let scheme = "jp.ez-net.scheme.codepiece.authentication"
	let host = "gist"
	
	func action(url: URL) {
		
		Authorization.github.oauth2.handleRedirectURL(url)
	}
}
