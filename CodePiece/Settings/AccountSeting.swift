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
	
	var authorization:GitHubAuthorization?
}

extension AccountSetting {
	
	var isAuthorized:Bool {
		
		return self.authorization != nil
	}
}
