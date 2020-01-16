//
//  User.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

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

	enum CodingKeys : String, CodingKey {
		
		case name
		case profile
		case createdAt = "created_at"
		case location
		case isTranslationEnabled = "is_translation_enabled"
		case isTranslator = "is_translator"
		case followRequestSent = "follow_request_sent"
		case idStr = "id_str"
		case entities
		case defaultProfile = "default_profile"
		case contributorsEnabled = "contributors_enabled"
		case url
		case favouritesCount = "favourites_count"
		case utcOffset = "utc_offset"
		case id
		case listedCount = "listed_count"
		case protected
		case lang
		case followersCount = "followers_count"
		case timeZone = "time_zone"
		case verified
		case notifications
		case description
		case geoEnabled = "geo_enabled"
		case statusesCount = "statuses_count"
		case defaultProfileImage = "default_profile_image"
		case friendsCount = "friends_count"
		case showAllInlineMedia = "show_all_inline_media"
		case screenName = "screen_name"
		case following
	}
}

