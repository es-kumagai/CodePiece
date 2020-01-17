//
//  TwitterAccount.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 8/24/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Accounts

@available(*, unavailable, renamed: "TwitterController.Account")
typealias TwitterAccount = TwitterController.Account

extension TwitterController {
	
	enum Account {
		
		case token(token: String, tokenSecret: String, screenName: String)
	}
}

extension TwitterController.Account {
	
	init(token: String, tokenSecret: String, screenName: String) {
		
		self = .token(token: token, tokenSecret: tokenSecret, screenName: screenName)
	}
}

extension TwitterController.Account {

	var storeKind: DataStore.TwitterStore.Kind {
		
		switch self {
			
		case .token:
			return .OAuthToken
		}
	}
	
	var token: (token: String, tokenSecret: String)? {
		
		if case let .token(token, tokenSecret, _) = self {
			
			return (token: token, tokenSecret: tokenSecret)
		}
		else {
			
			return nil
		}
	}
	
	var username: String {
		
		switch self {
			
		case let .token(_, _, screenName):
			return screenName
		}
	}
}
