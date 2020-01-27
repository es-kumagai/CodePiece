//
//  API.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import Swifter

public final class API {
	
	public typealias MediaId = String
	public typealias StatusId = String

	public typealias AuthorizationResult = Result<Token, AuthorizationError>
	public typealias PostTweetResult = Result<Status, PostError>
	public typealias PostMediaResult = Result<[MediaId], PostError>
	public typealias SearchResult = Result<[Status], PostError>
	public typealias ResetResult = Result<Void, ResetError>
	
	
	var rawApi: Swifter?

	public var isAuthorized: Bool
	public var isCredentialVerified: Bool
	
	public init(consumerKey key: String, tokenSecret secret: String) {
		
		rawApi = Swifter(consumerKey: key, consumerSecret: secret)
		isAuthorized = false
		isCredentialVerified = false
	}
	
	public init(consumerKey key: String, tokenSecret secret: String, oauthToken token: String, oauthTokenSecret tokenSecret: String) {
		
		rawApi = Swifter(consumerKey: key, consumerSecret: secret, oauthToken: token, oauthTokenSecret: tokenSecret)
		isAuthorized = true
		isCredentialVerified = false
	}
}

extension API {
	
	public func authorize(withCallbackUrl url: Foundation.URL, handler: @escaping (AuthorizationResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}

		func successHandler(accessToken: Credential.OAuthAccessToken?, response: URLResponse) {
			
			guard let accessToken = accessToken else {
			
				handler(.failure(.failedToGetAccessToken(response)))
				return
			}
			
			let token = Token(key: accessToken.key, secret: accessToken.secret, userId: accessToken.userID!, screenName: accessToken.screenName!)

			handler(.success(token))
		}
		
		func failureHandler(error: Error) {

			handler(.failure(.notAuthorized(error)))
		}
		
		api.authorize(withCallback: url, forceLogin: false, success: successHandler, failure: failureHandler)
	}
	
	public func post(tweet: String, options: PostOption = PostOption(), handler: @escaping (PostTweetResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}
		
		func successHandler(json: JSON) {
			
			do {
				
				let data = try json.serialized()
				let status = try JSONDecoder().decode(Status.self, from: data)
			
				handler(.success(status))
			}
			catch let error as DecodingError {
				
				handler(.failure(.parseError(error.localizedDescription)))
			}
			catch let error as JSON.SerializationError {

				handler(.failure(.unexpected(error)))
			}
			catch {

				handler(.failure(.internalError("Failed to serialize a JSON data. \(error)")))
			}
		}
		
		func failureHandler(error: Error) {
			
			switch error {
				
			case let error as SwifterError:
				handler(.failure(PostError(tweetError: error)))
				
			default:
				handler(.failure(.unexpected(error)))
			}
		}
		
		api.postTweet(status: tweet, inReplyToStatusID: options.inReplyTo, coordinate: options.coordinate.map { ($0.latitude, $0.longitude) }, autoPopulateReplyMetadata: options.autoPopulateReplyMetadata, excludeReplyUserIds: options.excludeReplyUserIds, placeID: options.placeId, displayCoordinates: options.displayCoordinates, trimUser: options.trimUser, mediaIDs: options.mediaIDs, attachmentURL: options.attachmentUrl, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
	}
	
	public func post(media: Data, additionalOwners: UsersTag? = nil, handler: @escaping (PostMediaResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}
		
		func successHandler(json: JSON) {
			
			#warning("ここで json から MediaID を取得します。")
			NSLog("%@", json.description)
			let mediaId = "0"

			handler(.success([mediaId]))
		}
		
		func failureHandler(error: Error) {
			
			switch error {
				
			case let error as SwifterError:
				handler(.failure(.init(tweetError: error)))
				
			default:
				handler(.failure(.unexpected(error)))
			}
		}
		
		api.postMedia(media, additionalOwners: additionalOwners.map(SwifterUsersTag.init), success: successHandler, failure: failureHandler)
	}
	
	public func search(usingQuery query: String, options: API.SearchOptions = API.SearchOptions(), handler: @escaping (SearchResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}
		
		func successHandler(json: JSON, metadata: JSON) {
			
			do {

				let data = try json.serialized()
				let statuses = try JSONDecoder().decode([Status].self, from: data)
			
				handler(.success(statuses))
			}
			catch let error as DecodingError {
				
				handler(.failure(.parseError(error.localizedDescription)))
			}
			catch let error as JSON.SerializationError {

				handler(.failure(.unexpected(error)))
			}
			catch {

				handler(.failure(.internalError("Failed to serialize a JSON data. \(error)")))
			}
		}
		
		func failureHandler(error: Error) {
			
			switch error {
				
			case let error as SwifterError:
				handler(.failure(.init(tweetError: error)))
				
			default:
				handler(.failure(.unexpected(error)))
			}
		}
		
		api.searchTweet(using: query, geocode: options.geocode, lang: options.language, locale: options.locale, resultType: options.resultType, count: options.count, until: options.until, sinceID: options.sinceId, maxID: options.maxId, includeEntities: options.includeEntities, callback: options.callback, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
	}
	
	public func reset(handler: @escaping (ResetResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}
		
		func successHandler(token: Credential.OAuthAccessToken?, urlResponse: URLResponse) {
			
			rawApi = nil
			isCredentialVerified = false
			
			handler(.success(()))
		}
		
		func failureHandler(error: Error) {

			handler(.failure(.unexpected(error)))
		}
		
		api.invalidateOAuth2BearerToken(success: successHandler, failure: failureHandler)
	}
}
