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
	
	public enum Error : ErrorType {
		
		case OperationFailure(reason:String)
	}
	
	private static func escape(string:String) throws -> String {
		
		let allowedCharacters = NSCharacterSet.alphanumericCharacterSet()
		
		guard let escaped = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) else {
			
			throw Error.OperationFailure(reason: "Failed to escape a parameter '\(string)'.")
		}
		
		return escaped
	}
	
	private static func open(url:NSURL) throws {
		
		guard NSWorkspace.sharedWorkspace().openURL(url) else {
			
			throw Error.OperationFailure(reason: "Failed to open URL '\(url)'.")
		}
	}
	
	public static func openWithUsername(username:String) throws {
		
		let string = "\(self.baseUrl)/\(username)"
		
		guard let url = NSURL(string: string) else {
			
			throw Error.OperationFailure(reason: "Failed to make URL for open twitter home '\(string)'.")
		}
		
		try open(url)
	}
	
	public static func openWithQuery(query:String, language:String? = nil) throws {
		
		let language = language ?? ""
		let string = try "\(self.searchUrl)?f=tweets&vertical=default&q=\(escape(query))&src=typd&lang=\(escape(language))"
		
		guard let url = NSURL(string: string) else {
			
			throw Error.OperationFailure(reason: "Failed to make URL for search '\(string)'.")
		}
		
		try open(url)
	}
}
