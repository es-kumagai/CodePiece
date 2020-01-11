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
            
            plist?["GitHubClientID"] ?? ""
        }
        
        static var clientSecret: String {
            
            plist?["GitHubClientSecret"] ?? ""
        }
    }
    
    /// APIKey data for Twitter.
    struct Twitter {
        
        static var consumerKey: String {
            
            plist?["TwitterConsumerKey"] ?? ""
        }
        
        static var consumerSecret: String {
            
            plist?["TwitterConsumerSecret"] ?? ""
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
