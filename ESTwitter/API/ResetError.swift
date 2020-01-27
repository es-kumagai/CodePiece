//
//  Error.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

public enum ResetError : Error {
	
	case apiError(APIError)
	case unexpected(Error)
}
