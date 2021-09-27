//
//  GistScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import CodePieceCore
import Sky_AppKit

final class GistScheme : URLScheme {
	
	#if DEBUG
	static let scheme = "jp.ez-net.scheme.codepiece-beta.authentication"
	#else
	static let scheme = "jp.ez-net.scheme.codepiece.authentication"
	#endif
	
	static let host = "gist"
	
	static func action(url: URL) throws {
		
		DebugTime.print("🙋🏻‍♀️ Detected URL scheme for Gist authentication.")
		Authorization.gist.oauth2.handleRedirectURL(url)
	}
}

