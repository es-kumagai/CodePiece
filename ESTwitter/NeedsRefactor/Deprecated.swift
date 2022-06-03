//
//  Deprecated.swift
//  ESTwitter
//  
//  Created by Tomohiro Kumagai on 2022/04/22
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import Foundation

#warning("Concurrency に対応したら削除されます。")
extension API {

	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	public typealias AuthorizationResult = Result<Token, AuthorizationError>

	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	public typealias PostTweetResult = Result<Status, PostError>

	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	public typealias PostMediaResult = Result<[MediaId], PostError>

	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	public typealias SearchResult = Result<[Status], GetStatusesError>

	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	public typealias BasicResult = Result<Void, APIError>
}
