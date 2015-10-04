//
//  User.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct User {
	
	public var name: String
	public var profile: Profile
	public var createdAt: Date
	public var location: String
	public var isTranslationEnabled: Bool
	public var isTranslator: Bool
	public var followRequestSent: Bool
	public var idStr: String
	public var entities: UserEntities
	public var defaultProfile: Bool
	public var contributorsEnabled: Bool
	public var url: URL?
	public var favouritesCount: Int
	public var utcOffset: Int?
	public var id: UInt64
	public var listedCount: Int
	public var protected: Bool
	public var lang: String
	public var followersCount: Int
	public var timeZone: String?
	public var verified: Bool
	public var notifications: Bool
	public var description: String
	public var geoEnabled: Bool
	public var statusesCount: Int
	public var defaultProfileImage: Bool
	public var friendsCount: Int
	public var showAllInlineMedia: Bool?
	public var screenName: String
	public var following: Bool
}

extension User : Decodable {

	public static func decode(e: Extractor) throws -> User {
		
		return try build(User.init)(
			
			e <| "name",
			User.Profile.decode(e),
			e <| "created_at",
			e <| "location",
			e <| "is_translation_enabled",
			e <| "is_translator",
			e <| "follow_request_sent",
			e <| "id_str",
			e <| "entities",
			e <| "default_profile",
			e <| "contributors_enabled",
			e <|? "url",
			e <| "favourites_count",
			e <|? "utc_offset",
			e <| "id",
			e <| "listed_count",
			e <| "protected",
			e <| "lang",
			e <| "followers_count",
			e <|? "time_zone",
			e <| "verified",
			e <| "notifications",
			e <| "description",
			e <| "geo_enabled",
			e <| "statuses_count",
			e <| "default_profile_image",
			e <| "friends_count",
			e <|? "show_all_inline_media",
			e <| "screen_name",
			e <| "following"
		)
	}
}

