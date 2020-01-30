//
//  APIKeys.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/12.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import Ocean

/// API Keys.
///
/// This class load APIKeys file each time referencing a static property for key or secret.
struct APIKeys {
	
	/**
	A key and a initial vector for decryption.
	**/
	
	/// APIKey data for GitHub.
	struct GitHub {
		
		static var clientId: String {
			
			return value(of: "GitHubClientID")
		}
		
		static var clientSecret: String {
			
			return value(of: "GitHubClientSecret")
		}
	}
	
	/// APIKey data for Twitter.
	struct Twitter {
		
		static var consumerKey: String {
			
			return value(of: "TwitterConsumerKey")
		}
		
		static var consumerSecret: String {
			
			return value(of: "TwitterConsumerSecret")
		}
	}
}

private extension APIKeys {
	
	/// URL of APIKeys file.
	static var plistUrl = Bundle.main.url(forResource: "APIKeys", withExtension: "plist")
	
	/// API Keys data.
	static var plist: Dictionary<String, Any>? {
		
		guard let url = plistUrl else {
			
			return nil
		}
		
		return NSDictionary(contentsOf: url) as? Dictionary<String, String>
	}
	
	static func stringValueFromPlistDirectly(_ name: String) -> String? {
		
		return plist?[name] as? String
	}
	
	static func dataValueFromPlistDirectly(_ name: String) -> Data? {
		
		return plist?[name] as? Data
	}
	
	static func value(of name: String) -> String {
		
		#if DEBUG
		if let value = dataValueFromPlistDirectly("\(name)-Crypted-Beta") {
		
			return try! chiper.decrypto(value, initialVector: iv)
		}
		
		if let value = stringValueFromPlistDirectly("\(name)-Beta") {
			
			return value
		}
		#endif

		if let value = dataValueFromPlistDirectly("\(name)-Crypted") {
		
			return try! chiper.decrypto(value, initialVector: iv)
		}

		return stringValueFromPlistDirectly(name) ?? ""
	}
}
