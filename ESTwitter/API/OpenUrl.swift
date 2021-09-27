//
//  OpenUrl.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import Swifter

public func handle(openUrl url: URL) {
	
	Swifter.handleOpenURL(url, callbackURL: url)
}

