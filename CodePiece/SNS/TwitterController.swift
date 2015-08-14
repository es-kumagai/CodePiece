//
//  TwitterController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import STTwitter
import ESGists
import Accounts
import Result
import Ocean
import ESThread

enum TwitterAccount {
	
	case First
	case Specified(String)
}

final class TwitterController : PostController, AlertDisplayable {
	
	var account:TwitterAccount {
		
		didSet {
			
			defer {
				
				Authorization.TwitterAuthorizationStateDidChangeNotification(username: self.account.ACAccount?.username).post()
			}
			
			self.api = nil
			self.credentialsVerified = false
		}
	}
	
	private lazy var api:STTwitterAPI! = self.account.api

	private static let accountStore:ACAccountStore = ACAccountStore()
	private let accountType:ACAccountType = TwitterController.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
	private let accountOptions:[NSObject:AnyObject]? = nil
	
	private(set) var credentialsVerified:Bool
	private(set) var username:String!
	private(set) var userId:String!
 
	typealias VerifyResult = Result<Void,NSError>
	typealias PostStatusUpdateResult = Result<String,NSError>

	init?(account:TwitterAccount) {
		
		self.account = account
		self.credentialsVerified = false
		
		guard self.api != nil else {
			
			return nil
		}
	}

	var canPost:Bool {
		
		return self.credentialsVerified
	}
	
	func verifyCredentialsIfNeed(callback:(VerifyResult)->Void) {
		
		guard !self.credentialsVerified else {

			callback(VerifyResult(value: ()))
			return
		}
		
		self.verifyCredentials(callback)
	}
	
	func verifyCredentials(callback:(VerifyResult)->Void) {
		
		self.api.verifyCredentials { result in
			
			defer {
			
				Authorization.TwitterAuthorizationStateDidChangeNotification(username: self.username).post()
			}
			
			switch result {
				
			case let .Success(username, userId):
				
				self.credentialsVerified = true
				self.username = username
				self.userId = userId
				
				callback(VerifyResult(value:()))
				
			case let .Failure(error):

				self.credentialsVerified = false
				self.username = nil
				self.userId = nil
				
				callback(VerifyResult(error: error))
			}
		}
	}

	private func makeStatusFrom(gist:ESGists.Gist?, description:String, hashtag:Twitter.Hashtag, var maxLength: Int? = nil) -> String? {
		
		if gist != nil {

			let twitterTotalCount = maxLength ?? 140
			let reserveUrlCount = 23
			let reserveGistCount = gist.map { _ in Twitter.SpecialCounting.Media.length } ?? 0
			
			maxLength = twitterTotalCount - reserveUrlCount - reserveGistCount
		}
		
		let appendAppTag = (gist != nil)
		
		return DescriptionGenerator(description, language: nil, hashtag: hashtag, appendAppTag: appendAppTag, maxLength: maxLength, appendString: gist?.urls.htmlUrl.description)
	}
	
	func post(gist:ESGists.Gist, language:ESGists.Language, description:String, hashtag:Twitter.Hashtag, image:NSImage? = nil, callback:(PostStatusUpdateResult)->Void) throws {

		let status = self.makeStatusFrom(gist, description: description, hashtag: hashtag)!
		
		try self.post(status, image: image, callback: callback)
	}

	func post(description:String, hashtag:Twitter.Hashtag, image:NSImage? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
		DebugTime.print("📮 Try to post by Twitter ... #3")
		
		let status = self.makeStatusFrom(nil, description: description, hashtag: hashtag)!
		
		try self.post(status, image: image, callback: callback)
	}

	func post(status: String, image:NSImage? = nil, inReplyToStatusID existingStatusID: String? = nil, latitude: String? = nil, longitude: String? = nil, placeID: String? = nil, displayCoordinates: NSNumber? = nil, trimUser: NSNumber? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
		
		guard self.credentialsVerified else {
			
			DebugTime.print("📮 Verification failure ... #3.1.1")
			throw SNSControllerError.CredentialsNotVerified
		}

		DebugTime.print("📮 Try posting by Twitter ... #3.2")
		
		self.api.postStatusUpdate(status, image: image, inReplyToStatusID: existingStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser) { result in
			
			DebugTime.print("📮 Posted by Twitter ... #3.2.1")
			
			switch result {
				
			case .Success(let objects):
				callback(PostStatusUpdateResult(value: objects["text"] as! String))
				
			case .Failure(let error):
				callback(PostStatusUpdateResult(error: error))
			}
		}
	}
}

extension TwitterController {

	typealias RequestAccessResult = Result<Void,NSError>
	
	func requestAccessToAccounts(completion:(RequestAccessResult) -> Void) {
		
		TwitterController.accountStore.requestAccessToAccountsWithType(self.accountType, options: self.accountOptions) { granted, error in
			
			if granted {
				
				completion(RequestAccessResult(value:()))
			}
			else {
				
				completion(RequestAccessResult(error: error ?? NSError(domain: "Not Permitted", code: 0, userInfo: nil)))
			}
		}
	}
	
	func getAccounts() -> [ACAccount] {
		
		guard let accounts = TwitterController.accountStore.accountsWithAccountType(self.accountType) as? [ACAccount] else {
			
			return []
		}
		
		return accounts
	}
	
	func getAccount(identifier:String) -> ACAccount? {
		
		return TwitterController.accountStore.accountWithIdentifier(identifier)
	}
}

extension TwitterAccount {
	
	private var api:STTwitterAPI? {
		
		switch self {
			
		case .First:
			return STTwitterAPI.twitterAPIOSWithFirstAccount()
			
		case .Specified:
			return self.ACAccount.map(STTwitterAPI.twitterAPIOSWithAccount)
		}
	}
	
	var ACAccount:Accounts.ACAccount? {
		
		switch self {
			
		case .First:
			return sns.twitter.getAccounts().first?.identifier.flatMap(sns.twitter.getAccount)
			
		case .Specified(let identifier):
			return sns.twitter.getAccount(identifier)
		}
	}
}

extension STTwitterAPI {
	
	typealias VerifyCredentialsResult = Result<(username:String,userId:String),NSError>
	typealias PostStatusUpdateResult = Result<[NSObject:AnyObject],NSError>
	
	func postStatusUpdate(status: String, image:NSImage? = nil, inReplyToStatusID existingStatusID: String? = nil, latitude: String? = nil, longitude: String? = nil, placeID: String? = nil, displayCoordinates: NSNumber? = nil, trimUser: NSNumber? = nil, callback:(PostStatusUpdateResult)->Void) {
		
		DebugTime.print("📮 Try to post a status by Twitter ... #3.3")
		
		let tweetSucceeded = { (objects:[NSObject:AnyObject]!) -> Void in
			
			DebugTime.print("📮 A status posted successfully (\(objects))... #3.3.1")
			callback(PostStatusUpdateResult(value: objects))
		}
		
		let tweetFailed = { (error:NSError!) -> Void in
			
			DebugTime.print("📮 Failed to post a status with failure (\(error)) ... #3.3.2")
			callback(PostStatusUpdateResult(error: error))
		}
		
		if let image = image {

			DebugTime.print("📮 Try posting with image ... #3.3.3.1")
			
			let tweetProgress = { (bytes:Int, processedBytes:Int, totalBytes:Int) -> Void in

				NSLog("bytes:\(bytes), processed:\(processedBytes), total:\(totalBytes)")
			}
			
			let data = image.TIFFRepresentation!
			let bitmap = NSBitmapImageRep(data: data)!
			let mediaData = bitmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [NSImageInterlaced : NSNumber(bool: true)])!

			let mediaDatas:[NSData] = [mediaData]
			let possiblySensitive:NSNumber = false

			DebugTime.print("📮 Try posting by API ... #3.3.3.2")
			
			self.postStatusUpdate(status, mediaDataArray: mediaDatas, possiblySensitive: possiblySensitive, inReplyToStatusID: existingStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, uploadProgressBlock: tweetProgress, successBlock: tweetSucceeded, errorBlock: tweetFailed)
		}
		else {

			DebugTime.print("📮 Try posting with no image by API ... #3.3.3.3")
			
			self.postStatusUpdate(status, inReplyToStatusID: existingStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, successBlock: tweetSucceeded, errorBlock: tweetFailed)
		}

		DebugTime.print("📮 Post requested by API ... #3.3.4")
	}
	
	func verifyCredentials(callback:(VerifyCredentialsResult)->Void) {

		let verifySucceeded = { (username:String!, userId:String!) -> Void in

			DebugTime.print("📮 Verification successfully (Name:\(username), ID:\(userId)) ... #3.4.2")
			callback(VerifyCredentialsResult(value:(username, userId)))
		}

		let verifyFailed = { (error:NSError!) -> Void in
			
			DebugTime.print("📮 Verification failed with error '\(error)' ... #3.4.2")
			callback(VerifyCredentialsResult(error: error))
		}
		
		DebugTime.print("📮 Try to verify credentials ... #3.4")
		
		invokeAsync(mainQueue) {

			DebugTime.print("📮 Start verifying ... #3.4.1")
			
			self.verifyCredentialsWithUserSuccessBlock(verifySucceeded, errorBlock: verifyFailed)
		}
	}
}