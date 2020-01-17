//
//  Swifter.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/17.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import Swifter
import ESTwitter

// MARK: - Data Type
extension Swifter {

	typealias MediaID = String
	
	typealias AutorizationResult = Result<(Credential.OAuthAccessToken?, userName: String, userId: String, URLResponse), Error>
	typealias PostTweetResult = Result<ESTwitter.Status, SNSController.PostError>
	typealias PostMediaResult = Result<[MediaID], Error>
	typealias SearchResult = Result<(JSON, JSON), Error>
}

// MARK: -
