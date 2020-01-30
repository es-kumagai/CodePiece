//
//  Browse.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/05.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

public final class Browser {
	
	public static let baseUrl = "https://twitter.com"
	public static let searchUrl = "https://twitter.com/search"
	
	public enum BrowseError : Error {
		
		case OperationFailure(reason:String)
	}
	
	private static func escape(string: String) throws -> String {
		
		let allowedCharacters = NSCharacterSet.alphanumerics
		
		guard let escaped = (string as NSString).addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
			
			throw BrowseError.OperationFailure(reason: "Failed to escaping a parameter '\(string)'.")
		}
		
		return escaped
	}
	
	private static func open(url: Foundation.URL) throws {
		
		guard NSWorkspace.shared.open(url) else {
			
			throw BrowseError.OperationFailure(reason: "Failed to open URL '\(url)'.")
		}
	}
	
	public static func openWithStatus(status:ESTwitter.Status) throws {
		
		let string = "\(self.baseUrl)/\(status.user.screenName)/status/\(status.idStr)"
		
		guard let url = Foundation.URL(string: string) else {
			
			throw BrowseError.OperationFailure(reason: "Failed to make the URL for open tweet item: '\(string)'")
		}
		
		try open(url: url)
	}
	
	public static func openWithUsername(username:String) throws {
		
		let string = "\(self.baseUrl)/\(username)"
		
		guard let url = Foundation.URL(string: string) else {
			
			throw BrowseError.OperationFailure(reason: "Failed to make the URL for open twitter home: \(string)")
		}
		
		try open(url: url)
	}
	
	public static func openWithQuery(query:String, language:String? = nil) throws {
		
		let language = language ?? ""
		let string = try "\(self.searchUrl)?f=tweets&vertical=default&q=\(escape(string: query))&src=typd&lang=\(escape(string: language))"
		
		guard let url = Foundation.URL(string: string) else {
			
			throw BrowseError.OperationFailure(reason: "Failed to make the URL for searching tweet: \(string)")
		}
		
		try open(url: url)
	}
}
