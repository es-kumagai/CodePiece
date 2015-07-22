//
//  AccountSeting.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESGist

struct AccountSetting {
	
	var id:ID?
	var username:String?
	var authorization:GitHubAuthorization?
	
	var twitterAccount:TwitterAccount?
}

extension AccountSetting {

}

extension AccountSetting {
	
	var authorizationState:AuthorizationState {
		
		if self.id != nil {

			return authorization != nil ? .Authorized : .AuthorizedWithNoToken
		}
		else {
			
			return .NotAuthorized
		}
	}
}
