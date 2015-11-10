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
		
		return try build(URLInfo.init)(
		
			e <|? "display_url",
			e <|? "expanded_url",
			e <| "url",
			e <| "indices"
		)
	}
}
