//
//  TwitterController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import STTwitter
import ESGist
import Accounts
import Result
import Ocean

enum TwitterAccount {
	
	case First
	case Specified(String)
}

final class TwitterController : PostController, AlertDisplayable {
	
	private(set) var api:STTwitterAPI
	
	private(set) var credentialsVerified:Bool
	private(set) var username:String!
	private(set) var userId:String!
 
	typealias VerifyResult = Result<Void,NSError>
	typealias PostStatusUpdateResult = Result<String,NSError>

	init?(account:TwitterAccount) {
		
		self.credentialsVerified = false
		
		guard let api = account.api else {
			
			self.api = STTwitterAPI()
			return nil
		}
		
		self.api = api
	}

	func verifyCredentialsIfNeed(callback:(VerifyResult)->Void) {
		
		guard !self.credentialsVerified else {
			
			return
		}
		
		self.verifyCredentials(callback)
	}
	
	func verifyCredentials(callback:(VerifyResult)->Void) {
		
		self.api.verifyCredentials { result in
			
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

	private func makeStatusFrom(gist:ESGist.Gist?, description:String, hashtag:String, var maxLength: Int? = nil) -> String? {
		
		if gist != nil {

			let twitterTotalCount = maxLength ?? 140
			let reserveUrlCount = 23
			
			maxLength = twitterTotalCount - reserveUrlCount
		}
		
		let appendAppTag = (gist != nil)
		
		return DescriptionGenerator(description, language: nil, hashtag: hashtag, appendAppTag: appendAppTag, maxLength: maxLength, appendString: gist?.urls.htmlUrl.description)
	}
	
	func post(gist:ESGist.Gist, language:ESGist.Language, description:String, hashtag:String, image:NSImage? = nil, callback:(PostStatusUpdateResult)->Void) throws {

		let status = self.makeStatusFrom(gist, description: description, hashtag: hashtag)!
		
		try self.post(status, image: image, callback: callback)
	}

	func post(description:String, hashtag:String, image:NSImage? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
		let status = self.makeStatusFrom(nil, description: description, hashtag: hashtag)!
		
		try self.post(status, image: image, callback: callback)
	}

	func post(status: String, image:NSImage? = nil, inReplyToStatusID existingStatusID: String? = nil, latitude: String? = nil, longitude: String? = nil, placeID: String? = nil, displayCoordinates: NSNumber? = nil, trimUser: NSNumber? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
		NSLog("Will post to twitter: \(status)")
		
		guard self.credentialsVerified else {
			
			throw SNSControllerError.CredentialsNotVerified
		}

		self.api.postStatusUpdate(status, image: image, inReplyToStatusID: existingStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser) { result in
			
			switch result {
				
			case .Success(let objects):
				callback(PostStatusUpdateResult(value: objects["text"] as! String))
				
			case .Failure(let error):
				callback(PostStatusUpdateResult(error: error))
			}
		}
	}
}

extension TwitterAccount {
	
	private var api:STTwitterAPI? {
		
		switch self {
			
		case .First:
			return STTwitterAPI.twitterAPIOSWithFirstAccount()
			
		case .Specified(let identifier):
			let account:ACAccount? = ACAccountStore().accountWithIdentifier(identifier)
			return account.map(STTwitterAPI.twitterAPIOSWithAccount)
		}
	}
}

extension STTwitterAPI {
	
	typealias VerifyCredentialsResult = Result<(username:String,userId:String),NSError>
	typealias PostStatusUpdateResult = Result<[NSObject:AnyObject],NSError>
	
	func postStatusUpdate(status: String, image:NSImage? = nil, inReplyToStatusID existingStatusID: String? = nil, latitude: String? = nil, longitude: String? = nil, placeID: String? = nil, displayCoordinates: NSNumber? = nil, trimUser: NSNumber? = nil, callback:(PostStatusUpdateResult)->Void) {
		
		let tweetSucceeded = { (objects:[NSObject:AnyObject]!) -> Void in
			
			callback(PostStatusUpdateResult(value: objects))
		}
		
		let tweetFailed = { (error:NSError!) -> Void in
			
			callback(PostStatusUpdateResult(error: error))
		}
		
		if let image = image {

			let tweetProgress = { (bytes:Int, processedBytes:Int, totalBytes:Int) -> Void in

				NSLog("bytes:\(bytes), processed:\(processedBytes), total:\(totalBytes)")
			}
			
			let data = image.TIFFRepresentation!
			let bitmap = NSBitmapImageRep(data: data)!
			let mediaData = bitmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [NSImageInterlaced : NSNumber(bool: true)])!

			let mediaDatas:[NSData] = [mediaData]
			let possiblySensitive:NSNumber = false

			self.postStatusUpdate(status, mediaDataArray: mediaDatas, possiblySensitive: possiblySensitive, inReplyToStatusID: existingStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, uploadProgressBlock: tweetProgress, successBlock: tweetSucceeded, errorBlock: tweetFailed)
		}
		else {

			self.postStatusUpdate(status, inReplyToStatusID: existingStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, successBlock: tweetSucceeded, errorBlock: tweetFailed)
		}
	}
	
	func verifyCredentials(callback:(VerifyCredentialsResult)->Void) {

		let verifySucceeded = { (username:String!, userId:String!) -> Void in

			callback(VerifyCredentialsResult(value:(username, userId)))
		}

		let verifyFailed = { (error:NSError!) -> Void in
			
			callback(VerifyCredentialsResult(error: error))
		}
		
		invokeAsync(mainQueue) {

			self.verifyCredentialsWithUserSuccessBlock(verifySucceeded, errorBlock: verifyFailed)
		}
	}
}