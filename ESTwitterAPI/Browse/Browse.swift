//
//  Browse.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/05.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

public final class Browser {
	
	public static let searchUrl = "https://twitter.com/search"
	
	public enum Error : ErrorType {
		
		case OperationFailure(reason:String)
	}
	
	public static func openWithQuery(query:String, language:String? = nil) throws {
		
		let language = language ?? ""
		let allowedCharacters = NSCharacterSet.alphanumericCharacterSet()
		let escape: (String) throws -> String = {
			
			guard let escaped = $0.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) else {
				
				throw Error.OperationFailure(reason: "Failed to escape a parameter '\($0)'.")
			}
			
			return escaped
		}
		
		let string = try "\(self.searchUrl)?f=tweets&vertical=default&q=\(escape(query))&src=typd&lang=\(escape(language))"
		
		guard let url = NSURL(string: string) else {
			
			throw Error.OperationFailure(reason: "Failed to make URL for search '\(string)'.")
		}
		
		guard NSWorkspace.sharedWorkspace().openURL(url) else {
			
			throw Error.OperationFailure(reason: "Failed to open URL '\(url)'.")
		}
	}
}
