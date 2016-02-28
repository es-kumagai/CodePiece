//
//  URLInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public struct URLInfo {
	
	public var displayUrl:String?
	public var expandedUrl:URL?
	public var url:URL
	public var indices:Indices
}

extension URLInfo {

	public var effectiveUrl:URL {
		
		return self.expandedUrl ?? self.url
	}
}

extension URLInfo : CustomStringConvertible {

	public var description:String {
	
		return self.displayUrl ?? self.effectiveUrl.description
	}
}

extension URLInfo : Decodable {
	
	public static func decode(e: Extractor) throws -> URLInfo {
		
		return try URLInfo(
		
			displayUrl: e.valueOptional("display_url"),
			expandedUrl: e.valueOptional("expanded_url"),
			url: e.value("url"),
			indices: e.value("indices")
		)
	}
}
