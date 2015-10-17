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

final class TwitterController : NSObject, PostController, AlertDisplayable {
	
	typealias VerifyResult = Result<Void,NSError>
	typealias PostStatusUpdateResult = Result<String,NSError>
	typealias GetStatusesResult = Result<[ESTwitter.Status], NSError>
	
	private static let timeout:NSTimeInterval = 15.0
	private static let accountStore:ACAccountStore = ACAccountStore()
	private static let accountType:ACAccountType = TwitterController.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
	private static let accountOptions:[NSObject:AnyObject]? = nil
	
	private static let APINotReadyError = SNSControllerError.NotReady("Twitter API is not ready.")
	private static let APINotReadyNSError = NSError(domain: String(APINotReadyError), code: 0, userInfo: [NSLocalizedDescriptionKey:APINotReadyError.description])

	var account:TwitterAccount? {
		
		didSet {
			
			settings.account.twitterAccount = self.account
			settings.saveTwitterAccount()

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
		
		return tweak (STTwitterAPI.twitterAPIOSWithAccount(account.ACAccount, withDelegate:self)) {
			
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
	}
	
	convenience override init() {
	
		self.init(account: settings.account.twitterAccount)
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

	private func makeStatusFrom(gist:ESGists.Gist?, description:String, hashtag:ESTwitter.Hashtag, var maxLength: Int? = nil) -> String? {
		
		if gist != nil {

			let twitterTotalCount = maxLength ?? 140
			let reserveUrlCount = 23
			let reserveGistCount = gist.map { _ in Twitter.SpecialCounting.Media.length } ?? 0
			
			maxLength = twitterTotalCount - reserveUrlCount - reserveGistCount
		}
		
		let appendAppTag = false
		let language:Language? = gist?.files.first?.1.language
		
		return DescriptionGenerator(description, language: language, hashtag: hashtag, appendAppTag: appendAppTag, maxLength: maxLength, appendString: gist?.urls.htmlUrl.description)
	}
	
	func post(gist:ESGists.Gist, language:ESGists.Language, description:String, hashtag:ESTwitter.Hashtag, image:NSImage? = nil, callback:(PostStatusUpdateResult)->Void) throws {

		let status = self.makeStatusFrom(gist, description: description, hashtag: hashtag)!
		
		try self.post(status, image: image, callback: callback)
	}

	func post(description:String, hashtag:ESTwitter.Hashtag, image:NSImage? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
		DebugTime.print("📮 Try to post by Twitter ... #3")
		
		let status = self.makeStatusFrom(nil, description: description, hashtag: hashtag)!
		
		try self.post(status, image: image, callback: callback)
	}

	func post(status: String, image:NSImage? = nil, inReplyToStatusID existingStatusID: String? = nil, latitude: String? = nil, longitude: String? = nil, placeID: String? = nil, displayCoordinates: NSNumber? = nil, trimUser: NSNumber? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
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
		
		api.postStatusUpdate(status, image: image, inReplyToStatusID: existingStatusID, latitude: latitude, longitude: longitude, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser) { result in
			
			DebugTime.print("📮 Posted by Twitter ... #3.2.1")
			
			switch result {
				
			case .Success(let objects):
				callback(PostStatusUpdateResult(value: objects["text"] as! String))
				
			case .Failure(let error):
				callback(PostStatusUpdateResult(error: error))
			}
		}
	}
	
	func getStatusesWithQuery(query:String, since:String?, callback:(GetStatusesResult)->Void) {
		
		let successHandler = { (query:[NSObject : AnyObject]!, resultData:[AnyObject]!) -> Void in
			
			NSLog("DEBUG : Get Statuses : \(query), \(resultData)")
			
			do {

				let status = try decodeArray(resultData) as [ESTwitter.Status]
				
				callback(GetStatusesResult(status))
			}
			catch let error as DecodeError {
				
				callback(GetStatusesResult(error: NSError(domain: "DecodeError", code: 0, userInfo: [ NSLocalizedDescriptionKey : "\(error.description)" ])))
			}
			catch let error as NSError {
				
				callback(GetStatusesResult(error: error))
			}
		}
		
		let errorHandler = { (error: NSError!) -> Void in
			
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

extension TwitterController : STTwitterAPIDelegate {
	
	func twitterAPI(api: STTwitterAPI!, shouldDisableCurrentOAuth oauth: STTwitterOS!, accountStore: ACAccountStore!) -> Bool {
		
		NSLog("Detected OS Account Store change.")
		
		guard self.credentialsVerified else {
			
			NSLog("This change is no effect on the current account because the account's credentials is not verifyed yet.")
			return false
		}
		
		api.verifyCredentials { result in
			
			switch result {
				
			case .Success:
				NSLog("This change is no effect on the current account.")
				
			case .Failure:
				
				self.clearEffectiveUserInfo()
				self.showWarningAlert("Twitter Account is invalid.", message: "Your twitter account setting may be changed by OS. Please check your settings in Internet Account preferences pane.")
			}
		}
		
		return false
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