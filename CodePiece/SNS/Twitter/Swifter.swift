//
//  Swifter.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/17.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import Swifter

extension Swifter {
	
	typealias AutorizationResult = Result<(Credential.OAuthAccessToken?, URLResponse), Error>
	typealias PostResult = Result<JSON, Error>
	typealias SearchResult = Result<(JSON, JSON), Error>
	
	func authorize(withCallback url: URL, handler: @escaping (AutorizationResult) -> Void) {
		
		let successHandler: TokenSuccessHandler = { accessToken, response in
			
			handler(.success((accessToken, response)))
		}
		
		let failureHandler: FailureHandler = { error in
			
			handler(.failure(error))
		}
		
		authorize(withCallback: url, success: successHandler, failure: failureHandler)
	}
	
	func postTweet(container: PostDataContainer,
					inReplyToStatusID: String? = nil,
					coordinate: (lat: Double, long: Double)? = nil,
					autoPopulateReplyMetadata: Bool? = nil,
					excludeReplyUserIds: Bool? = nil,
					placeID: Double? = nil,
					displayCoordinates: Bool? = nil,
					trimUser: Bool? = nil,
					mediaIDs: [String] = [],
					attachmentURL: URL? = nil,
					tweetMode: TweetMode = .default,
					handler: @escaping (PostResult) -> Void) {
	
		let successHandler: SuccessHandler = { json in
			
			handler(.success(json))
		}
		
		let failureHandler: FailureHandler = { error in
			
			handler(.failure(error))
		}
		
		postTweet(status: "DUMMY", inReplyToStatusID: inReplyToStatusID, coordinate: coordinate, autoPopulateReplyMetadata: autoPopulateReplyMetadata, excludeReplyUserIds: excludeReplyUserIds, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, mediaIDs: mediaIDs, attachmentURL: attachmentURL, tweetMode: tweetMode, success: successHandler, failure: failureHandler)
	}
	
    func postMedia(container: PostDataContainer,
				   data: Data,
                   additionalOwners: UsersTag? = nil,
				   handler: @escaping (PostResult) -> Void) {
		
		let successHandler: SuccessHandler = { json in
			
			handler(.success(json))
		}
		
		let failureHandler: FailureHandler = { error in
			
			handler(.failure(error))
		}
		
		postMedia(data, additionalOwners: additionalOwners, success: successHandler, failure: failureHandler)
	}
	
    func searchTweet(using query: String,
                     geocode: String? = nil,
                     lang: String? = nil,
                     locale: String? = nil,
                     resultType: String? = nil,
                     count: Int? = nil,
                     until: String? = nil,
                     sinceID: String? = nil,
                     maxID: String? = nil,
                     includeEntities: Bool? = nil,
                     callback: String? = nil,
                     tweetMode: TweetMode = TweetMode.default,
					 handler: @escaping (SearchResult) -> Void) {

		let successHandler: SearchResultHandler = { json, searchMetaData in
			
			handler(.success(json, searchMetaData))
		}
		
		let failureHandler: FailureHandler = { error in
			
			handler(.failure(error))
		}
		
		searchTweet(using: query, geocode: geocode, lang: lang, locale: locale, resultType: resultType, count: count, until: until, sinceID: sinceID, maxID: maxID, includeEntities: includeEntities, callback: callback, tweetMode: tweetMode, success: successHandler, failure: failure)
	}
}
