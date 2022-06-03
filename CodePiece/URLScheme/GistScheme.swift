//
//  GistScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

@preconcurrency import struct Foundation.URL
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
		
		Task { @MainActor in
			
			DebugTime.print("🙋🏻‍♀️ Detected URL scheme for Gist authentication.")
			Authorization.gist.oauth2.handleRedirectURL(url)
		}
	}
}

