//
//  TwitterController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import STTwitter
import ESTwitter
import ESGists
import Accounts
import Result
import Ocean
import ESThread
import Swim
import Himotoki

struct TwitterAccount {
	
	var ACAccount:Accounts.ACAccount
	
	init(account:Accounts.ACAccount) {
	
		self.ACAccount = account
	}
	
	init?(identifier:String) {
	
		guard let account = TwitterController.getAccount(identifier) else {
			
			return nil
		}
		
		self.ACAccount = account
	}
	
	var username:String {
		
		return self.ACAccount.username
	}
	
	var identifier:String {
		
		return self.ACAccount.identifier!
	}
}

struct GetStatusesError : ErrorType, CustomStringConvertible {

	enum Type {
	
		case DecodeResultError
		case UnexpectedError
		
		// STTwitter
		case CouldNotAuthenticate
		case PageDoesNotExist
		case AccountSuspended
		case APIv1Inactive
		case RateLimitExceeded
		case InvalidOrExpiredToken
		case SSLRequired
		case OverCapacity
		case InternalError
		case CouldNotAuthenticateYou
		case UnableToFollow
		case NotAuthorizedToSeeStatus
		case DailyStatuUpdateLimitExceeded
		case DuplicatedStatus
		case BadAuthenticationData
		case UserMustVerifyLogin
		case RetiredEndpoint
		case ApplicationCannotWrite
	}
	
	var type: Type
	var reason: String
	
	var description: String {
		
		return "\(self.reason) (\(self.type))"
	}
	
	init(type: Type, reason: String) {
	
		self.type = type
		self.reason = reason
	}
	
	init(code: STTwitterTwitterErrorCode, reason: String) {
		
		self.reason = reason
		
		switch code {
			
		case .CouldNotAuthenticate:
			self.type = .CouldNotAuthenticate
			
		case .PageDoesNotExist:
			self.type = .PageDoesNotExist
			
		case .AccountSuspended:
			self.type = .AccountSuspended
			
		case .APIv1Inactive:
			self.type = .APIv1Inactive
			
		case .RateLimitExceeded:
			self.type = .RateLimitExceeded
			
		case .InvalidOrExpiredToken:
			self.type = .InvalidOrExpiredToken
			
		case .SSLRequired:
			self.type = .SSLRequired
			
		case .OverCapacity:
			self.type = .OverCapacity
			
		case .InternalError:
			self.type = .InternalError
			
		case .CouldNotAuthenticateYou:
			self.type = .CouldNotAuthenticateYou
			
		case .UnableToFollow:
			self.type = .UnableToFollow
			
		case .NotAuthorizedToSeeStatus:
			self.type = .NotAuthorizedToSeeStatus
			
		case .DailyStatuUpdateLimitExceeded:
			self.type = .DailyStatuUpdateLimitExceeded
			
		case .DuplicatedStatus:
			self.type = .DuplicatedStatus
			
		case .BadAuthenticationData:
			self.type = .BadAuthenticationData
			
		case .UserMustVerifyLogin:
			self.type = .UserMustVerifyLogin
			
		case .RetiredEndpoint:
			self.type = .RetiredEndpoint
			
		case .ApplicationCannotWrite:
			self.type = .ApplicationCannotWrite
		}
	}
}

final class TwitterController : NSObject, PostController, AlertDisplayable {
	
	typealias VerifyResult = Result<Void,NSError>
	typealias PostStatusUpdateResult = Result<String,NSError>
	typealias GetStatusesResult = Result<[ESTwitter.Status], GetStatusesError>
	
	private static let timeout:NSTimeInterval = 15.0
	private static let accountStore:ACAccountStore = ACAccountStore()
	private static let accountType:ACAccountType = TwitterController.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
	private static let accountOptions:[NSObject:AnyObject]? = nil
	
	private static let APINotReadyError = SNSControllerError.NotReady("Twitter API is not ready.")
	private static let APINotReadyNSError = NSError(domain: String(APINotReadyError), code: 0, userInfo: [NSLocalizedDescriptionKey:APINotReadyError.description])

	private enum AutoVerifyingQueueMessage : MessageTypeIgnoreInQuickSuccession {
	
		case RequestVerification;
		
		private func messageBlocked() {

			NSLog("Ignoring duplicated `Request Verification` message.")
		}
		
		private func messageQueued() {
			
			NSLog("queued")
		}
	}
	
	private var autoVerifyingNow: Bool = false
	private var autoVerifyingQueue:MessageQueue<AutoVerifyingQueueMessage>!
	
	var account:TwitterAccount? {
		
		didSet {
			
			NSApp.settings.account.twitterAccount = self.account
			NSApp.settings.saveTwitterAccount()

			self.api = nil
			self.clearEffectiveUserInfo()
		}
	}
	
	var readyToUse:Bool {
		
		return self.account != nil
	}

	private lazy var api:STTwitterAPI! = self._getAPI()
	
	private func _getAPI() -> STTwitterAPI? {

		guard let account = self.account else {
			
			return nil
		}
		
		return tweak (STTwitterAPI.twitterAPIOSWithAccount(account.ACAccount, delegate:self)) {
			
			$0.setTimeoutInSeconds(TwitterController.timeout)
		}
	}
	
	var credentialsVerified:Bool {
		
		return self.effectiveUserInfo != nil
	}
	
	private(set) var effectiveUserInfo:UserInfo? {
		
		willSet {
			
			self.willChangeValueForKey("credentialsVerified")
			self.willChangeValueForKey("canPost")
		}
		
		didSet {
			
			self.didChangeValueForKey("credentialsVerified")
			self.didChangeValueForKey("canPost")
		}
	}
 
	private init(account:TwitterAccount?) {
		
		self.account = account
		self.effectiveUserInfo = nil
		
		super.init()
		
		self.autoVerifyingQueue = MessageQueue<AutoVerifyingQueueMessage>(identifier: "\(self.dynamicType)", executionQueue: dispatch_get_main_queue(), processingInterval: 5.0) { message in

			switch message {
				
			case .RequestVerification:
				self.autoVerifyingAction()
			}
		}
		
		self.autoVerifyingQueue.start()
	}
	
	convenience override init() {
	
		self.init(account: NSApp.settings.account.twitterAccount)
	}
	
	private func autoVerifyingAction() {
		
		guard !self.autoVerifyingNow else {
			
			return
		}
		
		guard self.credentialsVerified else {
			
			NSLog("This change is no effect on the current account because the account's credentials is not verifyed yet.")
			return
		}
		
		self.autoVerifyingNow = true
		
		api.verifyCredentials { result in
		
			defer {
			
				self.autoVerifyingNow = false
			}
			
			switch result {
				
			case .Success:
				NSLog("This change is no effect on the current account.")
				
			case .Failure:
				
				self.clearEffectiveUserInfo()
				self.showWarningAlert("Twitter Account is invalid.", message: "Your twitter account setting may be changed by OS. Please check your settings in Internet Account preferences pane.")
			}
		}
	}
	
	var canPost:Bool {
		
		return self.credentialsVerified
	}
	
	func clearEffectiveUserInfo() {
		
		self.effectiveUserInfo = nil
		
		Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
	}

	func verifyCredentialsIfNeed() -> Bool {
		
		DebugTime.print("📮 Passed verify-credentials #1")
		return self.verifyCredentialsIfNeed(self.verifyCredentialsBasicErrorReportCallback)
	}
	
	func verifyCredentialsIfNeed(callback:(VerifyResult)->Void) -> Bool {
		
		DebugTime.print("📮 Passed verify-credentials #2")
		guard self.readyToUse else {
			
			NSLog("Credentials verification skipped because it is not ready to use Twitter.")
			return false
		}
		
		DebugTime.print("📮 Passed verify-credentials #3")
		guard !self.credentialsVerified else {

			NSLog("Credentials already verifyed.")
			return false
		}
		
		DebugTime.print("📮 Passed verify-credentials #4")
		self.verifyCredentials(callback)

		DebugTime.print("📮 Passed verify-credentials #5")
		return true
	}
	
	private func verifyCredentialsBasicErrorReportCallback(result:VerifyResult) -> Void {
		
		DebugTime.print("📮 Passed verify-credentials #11")
		switch result {
			
		case .Success:
			DebugTime.print("📮 Passed verify-credentials #12")
			NSLog("Twitter credentials verified successfully. (\(NSApp.twitterController.effectiveUserInfo?.username))")
			
		case .Failure(let error):
			DebugTime.print("📮 Passed verify-credentials #13")
			self.showErrorAlert("Failed to verify credentials", message: "\(error.localizedDescription) (\(NSApp.twitterController.effectiveUserInfo?.username))")
		}
	}
	
	func verifyCredentials() {
	
		self.verifyCredentials(self.verifyCredentialsBasicErrorReportCallback)
	}
	
	func verifyCredentials(callback:(VerifyResult)->Void) {
		
		DebugTime.print("📮 Passed verify-credentials #6")

		guard let api = self.api else {
		
			callback(VerifyResult(error: TwitterController.APINotReadyNSError))
			return
		}
		
		DebugTime.print("📮 Passed verify-credentials #7")
		api.verifyCredentials { result in
			
			DebugTime.print("📮 Passed verify-credentials #8")
			defer {
			
				Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: self.credentialsVerified, username: self.effectiveUserInfo?.username).post()
			}
			
			switch result {
				
			case let .Success(username, userId):
				
				DebugTime.print("📮 Passed verify-credentials #9")
				self.effectiveUserInfo = UserInfo(username: username, id: userId)
				callback(VerifyResult(value:()))
				
			case let .Failure(error):

				DebugTime.print("📮 Passed verify-credentials #10")
				self.effectiveUserInfo = nil
				callback(VerifyResult(error: error))
			}
		}
	}

	func post(container:PostDataContainer, latitude: String? = nil, longitude: String? = nil, placeID: String? = nil, displayCoordinates: NSNumber? = nil, trimUser: NSNumber? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
		
		guard let api = self.api else {
			
			DebugTime.print("📮 Twitter API for Verification is not ready ... #3.1.0")
			throw TwitterController.APINotReadyError
		}
		
		guard self.credentialsVerified else {
			
			DebugTime.print("📮 Verification failure ... #3.1.1")
			throw SNSControllerError.CredentialsNotVerified
		}

		DebugTime.print("📮 Try posting by Twitter ... #3.2")
		
		api.postStatusUpdate(container, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser) { result in
			
			DebugTime.print("📮 Posted by Twitter ... #3.2.1")
			
			switch result {
				
			case .Success(let objects):
				callback(PostStatusUpdateResult(value: objects["text"] as! String))
				
			case .Failure(let error):
				callback(PostStatusUpdateResult(error: error))
			}
		}
	}
	
	func postMedia(container:PostDataContainer, image:NSImage, callback:(PostResult)->Void) throws {
		
		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
		
		guard let api = self.api else {
			
			DebugTime.print("📮 Twitter API for Verification is not ready ... #3.1.0")
			throw TwitterController.APINotReadyError
		}
		
		guard self.credentialsVerified else {
			
			DebugTime.print("📮 Verification failure ... #3.1.1")
			throw SNSControllerError.CredentialsNotVerified
		}
		
		DebugTime.print("📮 Try posting by Twitter ... #3.2")
		
		api.postMediaUpload(container, image: image) { result in
			
			DebugTime.print("📮 Posted by Twitter ... #3.2.1")
			
			switch result {
				
			case .Success(let mediaIDs):

				container.setTwitterMediaIDs(mediaIDs)
				callback(PostResult.Success(container))
				
			case .Failure(let error):
				
				container.setError(PostError(error: error))
				callback(PostResult.Failure(container))
			}
		}
	}
	
	func getStatusesWithQuery(query:String, since:String?, callback:(GetStatusesResult)->Void) {
		
		let successHandler = { (query:[NSObject : AnyObject]!, resultData:[AnyObject]!) -> Void in

			DebugTime.print("Get Statuses : \(query)\n\(resultData)")
			
			do {

				let status = try decodeArray(resultData) as [ESTwitter.Status]
				
				callback(GetStatusesResult(status))
			}
			catch let error as DecodeError {
				
				let error = GetStatusesError(type: .DecodeResultError, reason: error.description)

				callback(GetStatusesResult(error: error))
			}
			catch let error as NSError {
				
				let error = GetStatusesError(type: .UnexpectedError, reason: error.localizedDescription)

				callback(GetStatusesResult(error: error))
			}
		}
		
		let errorHandler = { (error: NSError!) -> Void in
			
			let code = STTwitterTwitterErrorCode(rawValue: error.code)!
			let reason = error.localizedDescription
			
			let error = GetStatusesError(code: code, reason: reason)
			
			callback(GetStatusesResult(error: error))
		}
		
		self.api.getSearchTweetsWithQuery(query, geocode: nil, lang: nil, locale: nil, resultType: "mixed", count: "50", until: nil, sinceID: since, maxID: nil, includeEntities: NSNumber(bool: false), callback: nil, successBlock: successHandler, errorBlock: errorHandler)
	}
}

extension TwitterController {

	typealias RequestAccessResult = Result<Void,NSError>
	
	struct UserInfo {
	
		var username:String
		var id:String
	}
	
	static func requestAccessToAccounts(completion:(RequestAccessResult) -> Void) {
		
		TwitterController.accountStore.requestAccessToAccountsWithType(self.accountType, options: self.accountOptions) { granted, error in
			
			if granted {
				
				completion(RequestAccessResult(value:()))
			}
			else {
				
				completion(RequestAccessResult(error: error ?? NSError(domain: "Not Permitted", code: 0, userInfo: nil)))
			}
		}
	}
	
	static func getAccounts() -> [ACAccount] {
		
		guard let accounts = self.accountStore.accountsWithAccountType(self.accountType) as? [ACAccount] else {
			
			return []
		}
		
		return accounts
	}
	
	static func getAccount(identifier:String) -> ACAccount? {
		
		return self.accountStore.accountWithIdentifier(identifier)
	}
	
	static func getSingleAccount() -> ACAccount? {
		
		let accounts = self.getAccounts()
		
		if accounts.count == 1 {
			
			return accounts.first!
		}
		else {
			
			return nil
		}
	}
}

extension TwitterController : STTwitterAPIOSProtocol {
	
	func twitterAPI(twitterAPI: STTwitterAPI!, accountWasInvalidated invalidatedAccount: ACAccount!) {
		
		NSLog("Detected OS Account Store change.")
		self.autoVerifyingQueue.send(.RequestVerification)
	}
}

extension STTwitterAPI {
	
	typealias MediaID = String
	typealias VerifyCredentialsResult = Result<(username:String,userId:String),NSError>
	typealias PostStatusUpdateResult = Result<[NSObject:AnyObject],NSError>
	typealias PostMediaUploadResult = Result<[MediaID],NSError>

	func postMediaUpload(container:PostDataContainer, image:NSImage, callback:(PostMediaUploadResult)->Void) {
	
		DebugTime.print("📮 Try uploading image for using twitter ... #3.3.3.1")
		
		let data = image.TIFFRepresentation!
		let bitmap = NSBitmapImageRep(data: data)!
		let mediaData = bitmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [NSImageInterlaced : NSNumber(bool: true)])!
		
		let tweetProgress = { (bytes:Int64, processedBytes:Int64, totalBytes:Int64) -> Void in
			
			DebugTime.print("bytes:\(bytes), processed:\(processedBytes), total:\(totalBytes)")
		}
		
		let mediaUploadSucceeded = { (imageDictionary:[NSObject : AnyObject]!, mediaID:String!, size:Int) -> Void in
			
			DebugTime.print("📮 A thumbnail media posted ... #3.3.3.2.1")
			container.setTwitterMediaIDs(mediaID)
			
			callback(PostMediaUploadResult(value: [mediaID]))
		}
		
		let mediaUpdateFailed = { (error: NSError!) -> Void in
			
			DebugTime.print("📮 Failed to updload a thumbnail media ... #3.3.3.2.2")
			callback(PostMediaUploadResult(error: error))
		}
		
		DebugTime.print("📮 Try posting by API ... #3.3.3.2")
		self.postMediaUploadData(mediaData, fileName: "thumbnail.png", uploadProgressBlock: tweetProgress, successBlock: mediaUploadSucceeded, errorBlock: mediaUpdateFailed)
	}
	
	func postStatusUpdate(container:PostDataContainer, latitude: String? = nil, longitude: String? = nil, placeID: String? = nil, displayCoordinates: NSNumber? = nil, trimUser: NSNumber? = nil, callback:(PostStatusUpdateResult)->Void) {
		
		DebugTime.print("📮 Try to post a status by Twitter ... #3.3")
		
		let tweetSucceeded = { (objects:[NSObject:AnyObject]!) -> Void in
			
			container.postedToTwitter(objects)
			
			DebugTime.print("📮 A status posted successfully (\(objects))... #3.3.1")
			callback(PostStatusUpdateResult(value: objects))
		}
		
		let tweetFailed = { (error:NSError!) -> Void in
			
			DebugTime.print("📮 Failed to post a status with failure (\(error)) ... #3.3.2")
			callback(PostStatusUpdateResult(error: error))
		}
		
		if container.hasMediaIDs {

			DebugTime.print("📮 Try posting with image ... #3.3.3.1")
			self.postStatusUpdate(container.descriptionForTwitter(), inReplyToStatusID: container.twitterReplyToStatusID, mediaIDs: container.twitterState.mediaIDs, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, successBlock: tweetSucceeded, errorBlock: tweetFailed)
		}
		else {

			DebugTime.print("📮 Try posting with no image by API ... #3.3.3.3")
			self.postStatusUpdate(container.descriptionForTwitter(), inReplyToStatusID: container.twitterReplyToStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, successBlock: tweetSucceeded, errorBlock: tweetFailed)
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