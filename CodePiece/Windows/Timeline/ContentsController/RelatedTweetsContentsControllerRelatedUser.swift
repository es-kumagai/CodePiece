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
	
	var tweetFromAllUsersQuery: String {
	
		let maxQueryCount = 500
		
		var result = ""
		let users = appeareDateDescendingOrderedUsers()
		
		for (offset, user) in users.enumerated() {
		
			let query = "\(offset != 0 ? " OR " : "")\(user.screenName)"
			
			guard query.count <= maxQueryCount else {
				
				NSLog("Query is truncated under %d characters: %@", maxQueryCount, result)
				return result
			}
			
			result = query
		}
		
		return result
	}
}
