//
//  API.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import Swifter

@MainActor
public final class API {
	
	public typealias MediaId = String
	public typealias StatusId = String
	
	var rawApi: Swifter?

	public var isAuthorized: Bool
	public var isCredentialVerified: Bool
	
	private var consumerKey: String
	private var tokenSecret: String
	
	public init(consumerKey key: String, tokenSecret secret: String) async {
		
		consumerKey = key
		tokenSecret = secret

		isAuthorized = false
		isCredentialVerified = false

		rawApi = makeUnauthorizedRawApi()
	}
	
	public init(consumerKey key: String, tokenSecret secret: String, oauthToken oToken: String, oauthTokenSecret oTokenSecret: String) async {

		consumerKey = key
		tokenSecret = secret
		
		isAuthorized = true
		isCredentialVerified = false

		rawApi = makeAuthorizedRawApi(oauthToken: oToken, oauthTokenSecret: oTokenSecret)
	}
}

extension API {
	
	private func makeUnauthorizedRawApi() -> Swifter {
	
		Swifter(consumerKey: consumerKey, consumerSecret: tokenSecret)
	}
	
	private func makeAuthorizedRawApi(oauthToken oToken: String, oauthTokenSecret oTokenSecret: String) -> Swifter {
	
		Swifter(consumerKey: consumerKey, consumerSecret: tokenSecret, oauthToken: oToken, oauthTokenSecret: oTokenSecret)
	}
	
	public func authorize(withCallbackUrl url: URL) async throws -> Token {
		
		guard let api = rawApi else {
			
			throw AuthorizationError.apiError(.notReady)
		}

		return try await withCheckedThrowingContinuation { continuation in
			
			func successHandler(accessToken: Credential.OAuthAccessToken?, response: URLResponse) {
				
				guard let accessToken = accessToken else {
				
					continuation.resume(throwing: AuthorizationError.failedToGetAccessToken(response))
					return
				}
				
				let token = Token(key: accessToken.key, secret: accessToken.secret, userId: accessToken.userID!, screenName: accessToken.screenName!)

				continuation.resume(returning: token)
			}
			
			func failureHandler(error: Error) {

				switch error {
					
				case let error as SwifterError:
					
					switch SwifterError.Response(error: error) {
						
					case let .some(response):
						continuation.resume(throwing: AuthorizationError.notAuthorized(message: response.message))

					case .none:
						continuation.resume(throwing: AuthorizationError.notAuthorized(message: error.message))
					}

				default:
					continuation.resume(throwing: AuthorizationError.notAuthorized(message: "\(error)"))
				}
			}
			
			api.authorize(withCallback: url, forceLogin: false, success: successHandler, failure: failureHandler)		}
	}
	
	public func post(tweet: String, options: PostOption = PostOption()) async throws -> Status {
		
		guard let api = rawApi else {
			
			throw PostError.apiError(.notReady, state: .beforePosted)
		}
		
		return try await withCheckedThrowingContinuation { continuation in
			
			func successHandler(json: JSON) {
				
				do {
					
					let data = try json.serialized()
					let status = try JSONDecoder().decode(Status.self, from: data)
					
					continuation.resume(with: .success(status))
				}
				catch let error as DecodingError {
					
					continuation.resume(with: .failure(PostError.parseError("\(error)", state: .afterPosted)))
				}
				catch let error as JSON.SerializationError {
					
					continuation.resume(with: .failure(PostError.unexpectedError(error, state: .afterPosted)))
				}
				catch {
					
					continuation.resume(with: .failure(PostError.internalError("Failed to serialize a JSON data. \(error)", state: .afterPosted)))
				}
			}
			
			func failureHandler(error: Error) {
				
				switch error {
					
				case let error as SwifterError:
					continuation.resume(with: .failure(PostError(tweetError: error)))
					
				default:
					continuation.resume(with: .failure(PostError.unexpectedError(error, state: .beforePosted)))
				}
			}
			
			api.postTweet(status: tweet, inReplyToStatusID: options.inReplyTo, coordinate: options.coordinate.map { ($0.latitude, $0.longitude) }, autoPopulateReplyMetadata: options.autoPopulateReplyMetadata, excludeReplyUserIds: options.excludeReplyUserIds, placeID: options.placeId, displayCoordinates: options.displayCoordinates, trimUser: options.trimUser, mediaIDs: options.mediaIDs, attachmentURL: options.attachmentUrl, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
		}
	}
	
	public func post(media: Data, additionalOwners: UsersTag? = nil) async throws -> [MediaId] {
		
		guard let api = rawApi else {
			
			throw PostError.apiError(.notReady, state: .beforePosted)
		}
		
		return try await withCheckedThrowingContinuation { continuation in
			
			func successHandler(json: JSON) {
				
				do {
					let data = try json.serialized()
					let media = try JSONDecoder().decode(Media.self, from: data)
					
					continuation.resume(with: .success([media.idString]))
				}
				catch let error as DecodingError {
					
					continuation.resume(with: .failure(PostError.parseError("\(error)", state: .afterPosted)))
				}
				catch let error as JSON.SerializationError {
					
					continuation.resume(with: .failure(PostError.unexpectedError(error, state: .afterPosted)))
				}
				catch {
					
					continuation.resume(with: .failure(PostError.internalError("Failed to serialize a JSON data. \(error)", state: .afterPosted)))
				}
			}
			
			func failureHandler(error: Error) {
				
				switch error {
					
				case let error as SwifterError:
					continuation.resume(with: .failure(PostError(tweetError: error)))
					
				default:
					continuation.resume(with: .failure(PostError.unexpectedError(error, state: .beforePosted)))
				}
			}
			
			api.postMedia(media, additionalOwners: additionalOwners.map(SwifterUsersTag.init), success: successHandler, failure: failureHandler)
		}
	}
	
	public func mentions(options: MentionOptions = MentionOptions()) async throws -> [Status] {
		
		guard let api = rawApi else {
			
			throw GetStatusesError.apiError(.notReady)
		}
		
		return try await withCheckedThrowingContinuation { continuation in

			func successHandler(json: JSON) {
				
				do {
					
					try continuation.resume(returning: statuses(from: json))
				}
				catch {
					
					continuation.resume(throwing: error)
				}
			}
			
			func failureHandler(error: Error) {

				switch error {
					
				case let error as SwifterError:
					continuation.resume(throwing: GetStatusesError(tweetError: error))
					
				case let error as NSError:
					continuation.resume(throwing: GetStatusesError(nsError: error))
					
				default:
					continuation.resume(throwing: GetStatusesError.unexpected(error))
				}
			}
			
			api.getMentionsTimelineTweets(count: options.count, sinceID: options.sinceId, maxID: options.maxId, trimUser: options.trimUser, contributorDetails: options.contributorDetails, includeEntities: options.includeEntities, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
		}
	}
	
	public func timeline(of user: UserSelector, options: TimelineOptions = .init()) async throws -> [Status] {
	
		guard let api = rawApi else {
			
			throw GetStatusesError.apiError(.notReady)
		}
		
		return try await withCheckedThrowingContinuation { continuation in

			func successHandler(json: JSON) {
				
				do {
					
					try continuation.resume(returning: statuses(from: json))
				}
				catch {
					
					continuation.resume(throwing: error)
				}
			}
			
			func failureHandler(error: Error) {
				
				continuation.resume(throwing: GetStatusesError(error: error))
			}
			
			api.getTimeline(for: UserTag(user), customParam: [:], count: options.count, sinceID: options.sinceId, maxID: options.maxId, trimUser: options.trimUser, excludeReplies: options.excludeReplies, includeRetweets: options.includeRetweets, contributorDetails: options.contributorDetails, includeEntities: options.includeEntities, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
		}
	}
	
	public func search(usingQuery query: String, options: SearchOptions = .init()) async throws -> [Status] {
		
		guard let api = rawApi else {
			
			throw GetStatusesError.apiError(.notReady)
		}
		
		return try await withCheckedThrowingContinuation { continuation in

			func successHandler(json: JSON, metadata: JSON) {
				
				do {
					
					try continuation.resume(returning: statuses(from: json))
				}
				catch {
					
					continuation.resume(throwing: error)
				}
			}
			
			func failureHandler(error: Error) {
				
				continuation.resume(throwing: GetStatusesError(error: error))
			}
			
			api.searchTweet(using: query, geocode: options.geocode, lang: options.language, locale: options.locale, resultType: options.resultType, count: options.count, until: options.until, sinceID: options.sinceId, maxID: options.maxId, includeEntities: options.includeEntities, callback: options.callback, tweetMode: SwifterTweetMode(options.tweetMode), success: successHandler, failure: failureHandler)
		}
	}
	
	public func verifyCredentials() async throws {
	
		guard let api = rawApi else {
			
			throw APIError.notReady
		}
		
		return try await withCheckedThrowingContinuation { continuation in
			
			func successHandler(json: JSON) {

				Task { @MainActor in
					
					isCredentialVerified = true
					continuation.resume()
				}
			}
			
			func failureHandler(error: Error) {

				Task { @MainActor in
					
					isCredentialVerified = false
					
					switch error {
						
					case let error as SwifterError:
						continuation.resume(throwing: APIError(from: error))
						
					case let error as NSError:
						continuation.resume(throwing: APIError(from: error))
						
					default:
						continuation.resume(throwing: APIError.unexpected(error))
					}
				}
			}
			
			api.verifyAccountCredentials(includeEntities: nil, skipStatus: nil, includeEmail: nil, success: successHandler, failure: failureHandler)
		}
	}
	
	public func reset() async throws {
		
		guard rawApi != nil else {
			
			throw APIError.notReady
		}
		
		return try await withCheckedThrowingContinuation { continuation in
			
			func successHandler() {

				Task { @MainActor in
					
					rawApi = makeUnauthorizedRawApi()
					isCredentialVerified = false
						
					continuation.resume()
				}
			}
			
			func failureHandler(error: Error) {

				Task { @MainActor in
					
					continuation.resume(throwing: APIError.unexpected(error))
				}
			}

			// FIXME: Swifter のサインアウト方法がわからないため、アプリ内の認証情報だけを削除します。
			successHandler()
		}
	}
}

private extension API {
	
	nonisolated func statuses(from json: JSON) throws -> [Status] {
		
		do {

			let data = try json.serialized()
			let statuses = try JSONDecoder().decode([Status].self, from: data)
		
			return statuses
		}
		catch let error as DecodingError {
			
			throw GetStatusesError.parseError("\(error)")
		}
		catch let error as JSON.SerializationError {

			throw GetStatusesError.unexpected(error)
		}
		catch {

			throw GetStatusesError.unexpectedWithDescription("Failed to serialize a JSON data. \(error)")
		}
	}
}
