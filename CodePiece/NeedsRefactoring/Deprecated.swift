//
//  Deprecated.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/22
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import ESTwitter

#warning("Concurrency に対応したら削除されます。")
extension TwitterController {
	
	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	typealias VerifyResult = Result<Void,NSError>

	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	typealias PostStatusUpdateResult = Result<String, SNSController.PostError>

	@available(*, deprecated, message: "Concurrency に対応したら削除されます。")
	typealias GetStatusesResult = API.SearchResult
}
