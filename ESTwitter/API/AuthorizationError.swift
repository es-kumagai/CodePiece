//
//  Error.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

public enum AuthorizationError : Error {
	
	case apiError(APIError)
	case notAuthorized(Error)
	case failedToGetAccessToken(URLResponse)
}
