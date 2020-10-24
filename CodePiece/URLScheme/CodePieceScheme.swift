//
//  CodePieceScheme.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/12.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter
import ESGists
import CodePieceCore

final class CodePieceScheme : URLScheme {
	
	#if DEBUG
	static let scheme = "codepiece-beta"
	#else
	static let scheme = "codepiece"
	#endif
	
	static let host = "open"
	
	static func action(url: Foundation.URL) {
		
		DebugTime.print("❕ Detected URL scheme for CodePiece open.")

		let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		
		guard let items = components.queryItems else {
			
			return
		}

		NSApp.moveToFront()
		
		for item in items {

			switch (item.name.lowercased(), item.value) {
				
			case ("hashtags", let value?):
				
				let hashtags = HashtagSet(hashtagsDisplayText: value)
				HashtagsChangeRequestNotification(hashtags: hashtags).post()
				
			case ("language", let value?):
				
				if let language = Language(displayText: value) {
					LanguageSelectionChangeRequestNotification(language: language).post()
				}
				
			case ("code", let value?):
				
				if let code = value.removingPercentEncoding {
					CodeChangeRequestNotification(code: code).post()
				}
				
			default:
				break
			}
		}
	}
}
