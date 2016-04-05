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
		
		return try User(
			
			name: e.value("name"),
			profile: decodeValue(e.rawValue),
			createdAt: e.value("created_at"),
			location: e.value("location"),
			isTranslationEnabled: e.value("is_translation_enabled"),
			isTranslator: e.value("is_translator"),
			followRequestSent: e.value("follow_request_sent"),
			idStr: e.value("id_str"),
			entities: e.value("entities"),
			defaultProfile: e.value("default_profile"),
			contributorsEnabled: e.value("contributors_enabled"),
			url: e.valueOptional("url"),
			favouritesCount: e.value("favourites_count"),
			utcOffset: e.valueOptional("utc_offset"),
			id: e.value("id"),
			listedCount: e.value("listed_count"),
			protected: e.value("protected"),
			lang: e.value("lang"),
			followersCount: e.value("followers_count"),
			timeZone: e.valueOptional("time_zone"),
			verified: e.value("verified"),
			notifications: e.value("notifications"),
			description: e.value("description"),
			geoEnabled: e.value("geo_enabled"),
			statusesCount: e.value("statuses_count"),
			defaultProfileImage: e.value("default_profile_image"),
			friendsCount: e.value("friends_count"),
			showAllInlineMedia: e.valueOptional("show_all_inline_media"),
			screenName: e.value("screen_name"),
			following: e.value("following")
		)
	}
}

