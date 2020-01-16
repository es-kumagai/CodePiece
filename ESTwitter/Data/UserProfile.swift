//
//  UserProfile.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

extension User {
	
	public struct Profile {
		
		public var sidebarBorderColor: Color
		public var sidebarFillColor: Color
		public var backgroundTile: Bool
		public var imageUrl: URL
		public var linkColor: Color
		public var imageUrlHttps: URL
		public var useBackgroundImage: Bool
		public var textColor: Color
		public var backgroundImageUrlHttps: URL?
		public var backgroundColor: Color
		public var backgroundImageUrl: URL?
	}
}

extension User.Profile : Decodable {
	
	public static func decode(e: Extractor) throws -> User.Profile {
		
		return try User.Profile(
			
			sidebarBorderColor: e.value("profile_sidebar_border_color"),
			sidebarFillColor: e.value("profile_sidebar_fill_color"),
			backgroundTile: e.value("profile_background_tile"),
			imageUrl: e.value("profile_image_url"),
			linkColor: e.value("profile_link_color"),
			imageUrlHttps: e.value("profile_image_url_https"),
			useBackgroundImage: e.value("profile_use_background_image"),
			textColor: e.value("profile_text_color"),
			backgroundImageUrlHttps: e.valueOptional("profile_background_image_url_https"),
			backgroundColor: e.value("profile_background_color"),
			backgroundImageUrl: e.valueOptional("profile_background_image_url")
		)
	}
}
