//
//  API.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import Swifter

public final class API {
	
	public typealias MediaId = String
	public typealias StatusId = String

	public typealias AuthorizationResult = Result<Token, AuthorizationError>
	public typealias PostTweetResult = Result<Status, PostError>
	public typealias PostMediaResult = Result<[MediaId], PostError>
	public typealias SearchResult = Result<[Status], GetStatusesError>
	public typealias BasicResult = Result<Void, APIError>
	
	
	var rawApi: Swifter?

	public var isAuthorized: Bool
	public var isCredentialVerified: Bool
	
	private var consumerKey: String
	private var tokenSecret: String
	
	public init(consumerKey key: String, tokenSecret secret: String) {
		
		consumerKey = key
		tokenSecret = secret

		isAuthorized = false
		isCredentialVerified = false

		rawApi = makeUnauthorizedRawApi()
	}
	
	public init(consumerKey key: String, tokenSecret secret: String, oauthToken oToken: String, oauthTokenSecret oTokenSecret: String) {

		consumerKey = key
		tokenSecret = secret
		
		isAuthorized = true
		isCredentialVerified = false

		rawApi = makeAuthorizedRawApi(oauthToken: oToken, oauthTokenSecret: oTokenSecret)
	}
}

extension API {
	
	private func makeUnauthorizedRawApi() -> Swifter {
	
		return Swifter(consumerKey: consumerKey, consumerSecret: tokenSecret)
	}
	
	private func makeAuthorizedRawApi(oauthToken oToken: String, oauthTokenSecret oTokenSecret: String) -> Swifter {
	
		return Swifter(consumerKey: consumerKey, consumerSecret: tokenSecret, oauthToken: oToken, oauthTokenSecret: oTokenSecret)
	}
	
	public func authorize(withCallbackUrl url: URL, handler: @escaping (AuthorizationResult) -> Void) {
		
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

			switch error {
				
			case let error as SwifterError:
				
				switch SwifterError.Response(error: error) {
					
				case let .some(response):
					handler(.failure(.notAuthorized(message: response.message)))

				case .none:
					handler(.failure(.notAuthorized(message: error.message)))
				}

			default:
				handler(.failure(.notAuthorized(message: "\(error)")))
			}
		}
		
		api.authorize(withCallback: url, forceLogin: false, success: successHandler, failure: failureHandler)
	}
	
	public func post(tweet: String, options: PostOption = PostOption(), handler: @escaping (PostTweetResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady, state: .beforePosted)))
			return
		}
		
		func successHandler(json: JSON) {
			
			do {
				
				let data = try json.serialized()
				let status = try JSONDecoder().decode(Status.self, from: data)
			
				handler(.success(status))
			}
			catch let error as DecodingError {
				
				handler(.failure(.parseError("\(error)", state: .afterPosted)))
			}
			catch let error as JSON.SerializationError {

				handler(.failure(.unexpectedError(error, state: .afterPosted)))
			}
			catch {

				handler(.failure(.internalError("Failed to serialize a JSON data. \(error)", state: .afterPosted)))
			}
		}
		
		func failureHandler(error: Error) {
			
			switch error {
				
			case let error as SwifterError:
				handler(.failure(PostError(tweetError: error)))
				
			default:
				handler(.failure(.unexpectedError(error, state: .beforePosted)))
			}
		}
		
		api.postTweet(status: tweet, inReplyToStatusID: options.inReplyTo, coordinate: options.coordinate.map { ($0.latitude, $0.longitude) }, autoPopulateReplyMetadata: options.autoPopulateReplyMetadata, excludeReplyUserIds: options.excludeReplyUserIds, placeID: options.placeId, displayCoordinates: options.displayCoordinates, trimUser: options.trimUser, mediaIDs: options.mediaIDs, attachmentURL: options.attachmentUrl, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
	}
	
	public func post(media: Data, additionalOwners: UsersTag? = nil, handler: @escaping (PostMediaResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady, state: .beforePosted)))
			return
		}
		
		func successHandler(json: JSON) {

			do {
				
				let data = try json.serialized()
				let media = try JSONDecoder().decode(Media.self, from: data)
				
				handler(.success([media.idString]))
			}
			catch let error as DecodingError {
				
				handler(.failure(.parseError("\(error)", state: .afterPosted)))
			}
			catch let error as JSON.SerializationError {
				
				handler(.failure(.unexpectedError(error, state: .afterPosted)))
			}
			catch {
				
				handler(.failure(.internalError("Failed to serialize a JSON data. \(error)", state: .afterPosted)))
			}
		}
		
		func failureHandler(error: Error) {
			
			switch error {
				
			case let error as SwifterError:
				handler(.failure(.init(tweetError: error)))
				
			default:
				handler(.failure(.unexpectedError(error, state: .beforePosted)))
			}
		}
		
		api.postMedia(media, additionalOwners: additionalOwners.map(SwifterUsersTag.init), success: successHandler, failure: failureHandler)
	}
	
	public func mentions(options: MentionOptions = .init(), handler: @escaping (SearchResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}
		
		func successHandler(json: JSON) {
			
			handler(statuses(from: json))
		}
		
		func failureHandler(error: Error) {
			
			handler(searchErrorResult(error))
		}
		
		api.getMentionsTimelineTweets(count: options.count, sinceID: options.sinceId, maxID: options.maxId, trimUser: options.trimUser, contributorDetails: options.contributorDetails, includeEntities: options.includeEntities, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
	}
	
	public func timeline(of user: UserSelector, options: TimelineOptions = .init(), handler: @escaping (SearchResult) -> Void) {
	
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}
		
		func successHandler(json: JSON) {
			
			handler(statuses(from: json))
		}
		
		func failureHandler(error: Error) {
			
			handler(searchErrorResult(error))
		}
		
		api.getTimeline(for: UserTag(user), customParam: [:], count: options.count, sinceID: options.sinceId, maxID: options.maxId, trimUser: options.trimUser, excludeReplies: options.excludeReplies, includeRetweets: options.includeRetweets, contributorDetails: options.contributorDetails, includeEntities: options.includeEntities, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
	}
	
	public func search(usingQuery query: String, options: SearchOptions = .init(), handler: @escaping (SearchResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.apiError(.notReady)))
			return
		}
		
		func successHandler(json: JSON, metadata: JSON) {
			
			handler(statuses(from: json))
		}
		
		func failureHandler(error: Error) {
			
			handler(searchErrorResult(error))
		}
		
		api.searchTweet(using: query, geocode: options.geocode, lang: options.language, locale: options.locale, resultType: options.resultType, count: options.count, until: options.until, sinceID: options.sinceId, maxID: options.maxId, includeEntities: options.includeEntities, callback: options.callback, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
	}
	
	public func verifyCredentials(handler: @escaping (BasicResult) -> Void) {
	
		guard let api = rawApi else {
			
			handler(.failure(.notReady))
			return
		}
		
		func successHandler(json: JSON) {
			
			isCredentialVerified = true
			handler(.success(()))
		}
		
		func failureHandler(error: Error) {

			isCredentialVerified = false
			
			switch error {
				
			case let error as SwifterError:
				handler(.failure(.init(from: error)))
				
			case let error as NSError:
				handler(.failure(.init(from: error)))
				
			default:
				handler(.failure(.unexpected(error)))
			}
		}
		
		api.verifyAccountCredentials(includeEntities: nil, skipStatus: nil, includeEmail: nil, success: successHandler, failure: failureHandler)
	}
	
	public func reset(handler: @escaping (BasicResult) -> Void) {
		
		guard let api = rawApi else {
			
			handler(.failure(.notReady))
			return
		}
		
		func successHandler() {
			
			rawApi = makeUnauthorizedRawApi()
			isCredentialVerified = false
			
			handler(.success(()))
		}
		
		func failureHandler(error: Error) {

			handler(.failure(.unexpected(error)))
		}

		// FIXME: Swifter のサインアウト方法がわからないため、アプリ内の認証情報だけを削除します。
		successHandler()
	}
}

private extension API {
	
	func statuses(from json: JSON) -> SearchResult {
		
		do {

			let data = try json.serialized()
			let statuses = try JSONDecoder().decode([Status].self, from: data)
		
			return .success(statuses)
		}
		catch let error as DecodingError {
			
			return .failure(.parseError("\(error)"))
		}
		catch let error as JSON.SerializationError {

			return .failure(.unexpected(error))
		}
		catch {

			return .failure(.unexpectedWithDescription("Failed to serialize a JSON data. \(error)"))
		}
	}
	
	func searchErrorResult(_ error: Error) -> SearchResult {
		
		switch error {
			
		case let error as SwifterError:
			return .failure(.init(tweetError: error))
			
		case let error as NSError:
			return .failure(.init(nsError: error))
			
		default:
			return .failure(.unexpected(error))
		}
	}
}
