//
//  NSError+STTwitter.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/15.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

public let kSTTwitterTwitterErrorDomain = "STTwitterTwitterErrorDomain"
public let kSTTwitterRateLimitLimit = "STTwitterRateLimitLimit"
public let kSTTwitterRateLimitRemaining = "STTwitterRateLimitRemaining"
public let kSTTwitterRateLimitResetDate = "STTwitterRateLimitResetDate"

// https://dev.twitter.com/docs/error-codes-responses
public enum STTwitterTwitterErrorCode : Int {
	
	case couldNotAuthenticate = 32 // Your call could not be completed as dialed.
	case pageDoesNotExist = 34 // Corresponds with an HTTP 404 - the specified resource was not found.
	case invalidAttachmentURL = 44 // Corresponds with HTTP 400. The URL value provided is not a URL that can be attached to this Tweet.
	case accountSuspended = 64 // Corresponds with an HTTP 403 — the access token being used belongs to a suspended user and they can't complete the action you're trying to take
	case apiV1Inactive = 68 // Corresponds to a HTTP request to a retired v1-era URL.
	case rateLimitExceeded = 88 // The request limit for this resource has been reached for the current rate limit window.
	case invalidOrExpiredToken = 89 // The access token used in the request is incorrect or has expired. Used in API v1.1
	case sslRequired = 92 // Only SSL connections are allowed in the API, you should update your request to a secure connection. See how to connect using SSL
	case overCapacity = 130 // Corresponds with an HTTP 503 - Twitter is temporarily over capacity.
	case internalError = 131 // Corresponds with an HTTP 500 - An unknown internal error occurred.
	case couldNotAuthenticateYou = 135 // Corresponds with a HTTP 401 - it means that your oauth_timestamp is either ahead or behind our acceptable range
	case unableToFollow = 161 // Corresponds with HTTP 403 — thrown when a user cannot follow another user due to some kind of limit
	case notAuthorizedToSeeStatus = 179 // Corresponds with HTTP 403 — thrown when a Tweet cannot be viewed by the authenticating user, usually due to the tweet's author having protected their tweets.
	case dailyStatuUpdateLimitExceeded = 185 // Corresponds with HTTP 403 — thrown when a tweet cannot be posted due to the user having no allowance remaining to post. Despite the text in the error message indicating that this error is only thrown when a daily limit is reached, this error will be thrown whenever a posting limitation has been reached. Posting allowances have roaming windows of time of unspecified duration.
	case duplicatedStatus = 187 // The status text has been Tweeted already by the authenticated account.
	case badAuthenticationData = 215 // Typically sent with 1.1 responses with HTTP code 400. The method requires authentication but it was not presented or was wholly invalid.
	case userMustVerifyLogin = 231 // Returned as a challenge in xAuth when the user has login verification enabled on their account and needs to be directed to twitter.com to generate a temporary password.
	case retiredEndpoint = 251 // Corresponds to a HTTP request to a retired URL.
	case applicationCannotWrite = 261 // Corresponds with HTTP 403 — thrown when the application is restricted from POST, PUT, or DELETE actions. See How to appeal application suspension and other disciplinary actions.
	case cannotReplyToDeletedOrInvisibleTweet = 385 // Corresponds with HTTP 403. A reply can only be sent with reference to an existing public Tweet.
	case tooManyAttachmentTypes = 386 // Corresponds with HTTP 403. A Tweet is limited to a single attachment resource (media, Quote Tweet, etc.)
}

extension NSError {
	
	static let st_xmlErrorRegex: NSRegularExpression = {
		
		return try! NSRegularExpression(pattern: "<error code=\"(.*)\">(.*)</error>", options: [])
		}()

	static func st_twitterError(from responseData: Data, responseHeaders: NSDictionary, underlyingError: NSError?) -> NSError? {
	
		let json: AnyObject?
		var jsonError: NSError?
		
		do {

			let json = try JSONSerialization.jsonObject(with: responseData, options: [.mutableLeaves]) as AnyObject
		}
		catch {
		
			jsonError = error as NSError
		}
		
		var message: String!
		var code: Int? = 0
		
		if let json = json as? NSDictionary {
			
			let errors = json.value(forKey: "errors") as AnyObject
			
			if errors is NSArray && errors.count > 0 {
				// assume format: {"errors":[{"message":"Sorry, that page does not exist","code":34}]}
				
				
				if let errorDictionary = errors.lastObject as? NSDictionary {
					
					message = errorDictionary["message"] as? String
					code = (errorDictionary.value(forKey: "code") as? String).flatMap(Int.init)
				}
			}
			else if let errors = json.value(forKey: "error") as? String {
				/*
				 eg. when requesting timeline from a protected account
				 {
				 error = "Not authorized.";
				 request = "/1.1/statuses/user_timeline.json?count=20&screen_name=premfe";
				 }
				 also, be robust to null errors such as in:
				 {
				 error = "<null>";
				 state = AwaitingComplete;
				 }
				 */
				message = errors
			}
			else if let errors = errors as? String {
				// assume format {errors = "Screen name can't be blank";}
				message = errors;
			}
		}
		
		if json == nil {
			// look for XML errors, eg.
			/*
			 <?xml version="1.0" encoding="UTF-8"?>
			 <errors>
			 <error code="87">Client is not permitted to perform this action</error>
			 </errors>
			 */
			
			let s = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue)!
			
			let xmlErrorRegex = st_xmlErrorRegex
			
			if let match = xmlErrorRegex.firstMatch(in: s as String, options: [], range: NSMakeRange(0, s.length)) {
				
				let group1Range = match.range(at: 1)
				let group2Range = match.range(at :2)
				
				let codeString = s.substring(with: group1Range)
				let errorMessaage = s.substring(with: group2Range)
				
				return NSError(domain: kSTTwitterTwitterErrorDomain, code: Int(codeString, radix: 10)!, userInfo: [NSLocalizedDescriptionKey : errorMessaage]);
			}
		}
		
		if message != nil {
			
			let rateLimitLimit = responseHeaders.value(forKey: "x-rate-limit-limit") as? String
			let rateLimitRemaining = responseHeaders.value(forKey: "x-rate-limit-remaining") as? String
			let rateLimitReset = responseHeaders.value(forKey: "x-rate-limit-reset") as? String
			
			let rateLimitResetDate: Date? = (rateLimitReset != nil) ? Date(timeIntervalSince1970: Double(rateLimitReset!)!) : nil
			
			let md = NSMutableDictionary()
			
			md[NSLocalizedDescriptionKey] = message;
			
			if underlyingError != nil { md[NSUnderlyingErrorKey] = underlyingError }
			if rateLimitLimit != nil { md[kSTTwitterRateLimitLimit] = rateLimitLimit }
			if rateLimitRemaining != nil { md[kSTTwitterRateLimitRemaining] = rateLimitRemaining }
			if rateLimitResetDate != nil { md[kSTTwitterRateLimitResetDate] = rateLimitResetDate }
			
			let userInfo = NSDictionary(dictionary: md)
			
			return NSError(domain: kSTTwitterTwitterErrorDomain, code: code, userInfo: userInfo)
		}
		
		return nil;
	}
}
