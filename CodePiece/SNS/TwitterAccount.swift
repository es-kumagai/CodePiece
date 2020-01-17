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
		
		case account(Accounts.ACAccount)
		case token(token: String, tokenSecret: String, screenName: String)
	}
}

extension TwitterController.Account {
	
	init(account: Accounts.ACAccount) {

		NSLog("🐋 Creates Twitter Account with OS Account.")
		self = .account(account)
	}
	
	init(token: String, tokenSecret: String, screenName: String) {
		
		self = .token(token: token, tokenSecret: tokenSecret, screenName: screenName)
	}
	
	init?(identifier:String) {
		
		guard let account = TwitterController.getAccount(identifier: identifier) else {
			
			return nil
		}
		
		NSLog("🐋 Creates Twitter Account with Identifier.")
		self = .account(account)
	}
}

extension TwitterController.Account {

	var storeKind: DataStore.TwitterStore.Kind {
		
		switch self {
			
		case .account:
			return .OSAccount
			
		case .token:
			return .OAuthToken
		}
	}
	
	var acAccount: Accounts.ACAccount? {
	
		switch self {
			
		case .account(let account):
			return account
			
		case .token:
			return nil
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
			
		case let .account(account):
			return account.username
			
		case let .token(_, _, screenName):
			return screenName
		}
	}
	
	var identifier: String? {
		
		return acAccount?.identifier as String?
	}
}
