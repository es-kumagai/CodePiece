//
//  URLInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct URLInfo : Decodable {
	
	public var displayUrl: String?
	public var expandedUrl: TwitterUrl?
	public var url: TwitterUrl
	public var indices: Indices
	
	public enum CodingKeys : String, CodingKey {
		
		case displayUrl = "display_url"
		case expandedUrl = "expanded_url"
		case url
		case indices
	}
}

extension URLInfo {

	public var effectiveUrl: TwitterUrl {
		
		return expandedUrl ?? url
	}
}

extension URLInfo : CustomStringConvertible {

	public var description: String {
	
		return displayUrl ?? effectiveUrl.description
	}
}
