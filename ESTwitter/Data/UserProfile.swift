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
	
	enum CodingKeys : String, CodingKey {
		
		case sidebarBorderColor = "profile_sidebar_border_color"
		case sidebarFillColor = "profile_sidebar_fill_color"
		case backgroundTile = "profile_background_tile"
		case imageUrl = "profile_image_url"
		case linkColor = "profile_link_color"
		case imageUrlHttps = "profile_image_url_https"
		case useBackgroundImage = "profile_use_background_image"
		case textColor = "profile_text_color"
		case backgroundImageUrlHttps = "profile_background_image_url_https"
		case backgroundColor = "profile_background_color"
		case backgroundImageUrl = "profile_background_image_url"
	}
}
