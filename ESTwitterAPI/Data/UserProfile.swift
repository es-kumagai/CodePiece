//
//  UserProfile.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

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
		
		return try build(User.Profile.init)(
			
			e <| "profile_sidebar_border_color",
			e <| "profile_sidebar_fill_color",
			e <| "profile_background_tile",
			e <| "profile_image_url",
			e <| "profile_link_color",
			e <| "profile_image_url_https",
			e <| "profile_use_background_image",
			e <| "profile_text_color",
			e <|? "profile_background_image_url_https",
			e <| "profile_background_color",
			e <|? "profile_background_image_url"
		)
	}
}