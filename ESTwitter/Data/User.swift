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
	public var hasExtendedProfile: Bool
	public var createdAt: TwitterDate
	public var location: String
	public var isTranslationEnabled: Bool
	public var isTranslator: Bool
	public var followRequestSent: Bool
	public var idStr: String
	public var entities: UserEntities
	public var defaultProfile: Bool
	public var contributorsEnabled: Bool
	public var url: TwitterUrl?
	public var favouritesCount: Int
	public var utcOffset: Int?
	public var id: UInt64
	public var listedCount: Int
	public var protected: Bool
	public var lang: String?
	public var followersCount: Int
	public var timeZone: String?
	public var verified: Bool
	public var notifications: Bool
	public var description: String
	public var geoEnabled: Bool
	public var statusesCount: Int
	public var defaultProfileImage: Bool
	public var friendsCount: Int
//	public var showAllInlineMedia: Bool?
	public var screenName: String
	public var following: Bool
}

extension User : Hashable {

	public func hash(into hasher: inout Hasher) {
		
		idStr.hash(into: &hasher)
	}
	
	public static func ==(lhs: User, rhs: User) -> Bool {
		
		return lhs.idStr == rhs.idStr
	}
}

extension User : Decodable {

	enum CodingKeys : String, CodingKey {
		
		case name
		case profileBackgroundImageUrlHttps = "profile_background_image_url_https"
		case profileBackgroundTile = "profile_background_tile"
		case hasExtendedProfile = "has_extended_profile"
		case profileImageUrlHttps = "profile_image_url_https"
		case profileUseBackgroundImage = "profile_use_background_image"
		case profileSidebarBorderColor = "profile_sidebar_border_color"
		case profileBackgroundColor = "profile_background_color"
		case profileImageUrl = "profile_image_url"
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
//		case showAllInlineMedia = "show_all_inline_media"
		case screenName = "screen_name"
		case following
	}
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		profile = try Profile(from: decoder)
		
		name = try container.decode(String.self, forKey: .name)
		hasExtendedProfile = try container.decode(Bool.self, forKey: .hasExtendedProfile)
		createdAt = try container.decode(TwitterDate.self, forKey: .createdAt)
		location = try container.decode(String.self, forKey: .location)
		isTranslationEnabled = try container.decode(Bool.self, forKey: .isTranslationEnabled)
		isTranslator = try container.decode(Bool.self, forKey: .isTranslator)
		followRequestSent = try container.decode(Bool.self, forKey: .followRequestSent)
		idStr = try container.decode(String.self, forKey: .idStr)
		entities = try container.decode(UserEntities.self, forKey: .entities)
		defaultProfile = try container.decode(Bool.self, forKey: .defaultProfile)
		contributorsEnabled = try container.decode(Bool.self, forKey: .contributorsEnabled)
		url = try container.decode(TwitterUrl?.self, forKey: .url)
		favouritesCount = try container.decode(Int.self, forKey: .favouritesCount)
		utcOffset = try container.decode(Int?.self, forKey: .utcOffset)
		id = try container.decode(UInt64.self, forKey: .id)
		listedCount = try container.decode(Int.self, forKey: .listedCount)
		protected = try container.decode(Bool.self, forKey: .protected)
		lang = try container.decode(String?.self, forKey: .lang)
		followersCount = try container.decode(Int.self, forKey: .followersCount)
		timeZone = try container.decode(String?.self, forKey: .timeZone)
		verified = try container.decode(Bool.self, forKey: .verified)
		notifications = try container.decode(Bool.self, forKey: .notifications)
		description = try container.decode(String.self, forKey: .description)
		geoEnabled = try container.decode(Bool.self, forKey: .geoEnabled)
		statusesCount = try container.decode(Int.self, forKey: .statusesCount)
		defaultProfileImage = try container.decode(Bool.self, forKey: .defaultProfileImage)
		friendsCount = try container.decode(Int.self, forKey: .friendsCount)
//		showAllInlineMedia = try container.decode(Bool?.self, forKey: .showAllInlineMedia)
		screenName = try container.decode(String.self, forKey: .screenName)
		following = try container.decode(Bool.self, forKey: .following)
	}
}

