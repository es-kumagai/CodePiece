//
//  PostData.swift
//  CodePieceCore
//
//  Created by kumagai on 2020/05/26.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import ESGists
import ESTwitter

public struct PostData : Sendable {
	
	public var code: Code
	public var description: String
	public var language: ESGists.Language
	@available(*, message: "HashtagSet に置き換えられるかもしれません。")
	public var hashtags: [Hashtag]
	public var usePublicGists: Bool
	public var replyTo: ESTwitter.Status?
	
	public var appendAppTagToTwitter: Bool
	
	public init(code: Code, description: String, language: ESGists.Language, hashtags: [Hashtag], usePublicGists: Bool, replyTo: ESTwitter.Status?, appendAppTagToTwitter: Bool = false) {
		
		self.code = code
		self.description = description
		self.language = language
		self.hashtags = hashtags
		self.usePublicGists = usePublicGists
		self.replyTo = replyTo
		self.appendAppTagToTwitter = appendAppTagToTwitter
	}
}
