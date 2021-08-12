//
//  RelatedTweetsContentsControllerRelatedUser.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/10.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import ESTwitter

extension RelatedTweetsContentsController {

	struct RelatedUser {
		
		var lastAppearedDate: Date
		var user: User
	}
}

extension RelatedTweetsContentsController.RelatedUser : Hashable {
	
	func hash(into hasher: inout Hasher) {
		
		user.hash(into: &hasher)
	}
	
	static func == (lhs: RelatedTweetsContentsController.RelatedUser, rhs: RelatedTweetsContentsController.RelatedUser) -> Bool {
		
		return lhs.user == rhs.user
	}
}

extension Set where Element == RelatedTweetsContentsController.RelatedUser {
	
	func appeareDateDescendingOrderedUsers() -> [User] {
	
		return sorted { $0.lastAppearedDate > $1.lastAppearedDate }
			.map { $0.user }
	}
	
	mutating func append<S: Sequence>(users: S) where S.Element == User {
		
		let relatedUsers = users.map {
		
			return Element(lastAppearedDate: Date(), user: $0)
		}
		
		formUnion(relatedUsers)
	}

	func tweetFromAllUsersQuery(withQueryLengthMargin queryLengthMargin: Int) -> String {
	
		let maxQueryLength = 500 - queryLengthMargin

		// FIXME: ここを first で result を初期化して、prefix(from:) で連結処理するようにすると、どういうコードになるんだろう。
		var result = ""

		for user in appeareDateDescendingOrderedUsers() {
		
			let query = "\(result)\(result.isEmpty ? "" : " OR ")from:\(user.screenName)"
			
			guard query.count <= maxQueryLength else {
				
				NSLog("Query is truncated characters to %d/%d: %@", result.count, maxQueryLength, result)
				
				return result
			}
			
			result = query
		}
		
		return result
	}
}
