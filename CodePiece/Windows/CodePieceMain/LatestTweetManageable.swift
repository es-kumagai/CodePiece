//
//  LatestTweetManageable.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/28/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import ESTwitter

protocol LatestTweetManageable : class {
	
	var latestTweet: ESTwitter.Status? { get }
	
	func resetLatestTweet()
}

extension LatestTweetManageable {

	var hasLatestTweet: Bool {
		
		return latestTweet != nil
	}
}
