//
//  APIKeys.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/12.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

/// API Keys.
///
/// This struct load APIKeys file each time referencing a static property for key or secret.
struct APIKeys {
    
    /// APIKey data for GitHub.
    struct GitHub {
        
        static var clientId: String {
            
			#if DEBUG
			if let id = plist?["GitHubClientID-Beta"] {
				return id
			}
			#endif

			return plist?["GitHubClientID"] ?? ""
        }
        
        static var clientSecret: String {
            
			#if DEBUG
			if let secret = plist?["GitHubClientSecret-Beta"] {
				return secret
			}
			#endif

            return plist?["GitHubClientSecret"] ?? ""
        }
    }
    
    /// APIKey data for Twitter.
    struct Twitter {
        
        static var consumerKey: String {
            
			#if DEBUG
			if let key = plist?["TwitterConsumerKey-Beta"] {
				return key
			}
			#endif
			
            return plist?["TwitterConsumerKey"] ?? ""
        }
        
        static var consumerSecret: String {
            
			#if DEBUG
			if let secret = plist?["TwitterConsumerSecret-Beta"] {
				return secret
			}
			#endif

			return plist?["TwitterConsumerSecret"] ?? ""
        }
    }
}

private extension APIKeys {
    
    /// URL of APIKeys file.
    static var plistUrl = Bundle.main.url(forResource: "APIKeys", withExtension: "plist")
    
    /// API Keys data.
    static var plist: Dictionary<String, String>? {
        
        guard let url = plistUrl else {
            
            return nil
        }
        
        return NSDictionary(contentsOf: url) as? Dictionary<String, String>
    }
}
