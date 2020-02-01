//
//  AccountSeting.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESGists
import ESTwitter

struct AccountSetting {
	
	var id: ID?
	var username: String?
	var authorization: GitHubAuthorization?
	
	var twitterToken: Token?
}

extension AccountSetting {

	// 設定がされていることを確認します。認証の正当性などは判定しません。
	var isReady:Bool {
		
		let isGistReady: ()->Bool = {

			// GitHub は Token が設定されているかで設定が有効かを判定します。
			self.authorization != nil
		}
		
		let isTwitterReady: ()->Bool = {

			//  Twitter はトークンが設定されていれば準備完了とします。その有効性は判定していません。
			return self.twitterToken != nil
		}
		
		return isGistReady() && isTwitterReady()
	}
}

extension AccountSetting {
	
	var authorizationState:AuthorizationState {
		
		if authorization != nil {

			return .authorized
		}
		else {
			
			return .notAuthorized
		}
	}
}
