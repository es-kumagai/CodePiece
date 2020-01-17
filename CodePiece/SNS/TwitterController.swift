//
//  TwitterController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter
import ESGists
import Accounts
import Ocean
import Swim
import Swifter

private let jsonDecoder = JSONDecoder()

struct GetStatusesError : Error, CustomStringConvertible {

	enum `Type` {
	
		case DecodeResultError
		case UnexpectedError
		
		// STTwitter
		case TwitterError(STTwitterTwitterErrorCode)
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
		self.type = .TwitterError(code)
	}
}

extension GetStatusesError {
	
	var isRateLimitExceeded: Bool {
		
		switch type {
			
		case .TwitterError(.rateLimitExceeded):
			return true
			
		default:
			return false
		}
	}
}

final class TwitterController : NSObject, PostController, AlertDisplayable {
	
	typealias VerifyResult = Result<Void,NSError>
	typealias PostStatusUpdateResult = Result<String, SNSController.PostError>
	typealias GetStatusesResult = Result<[ESTwitter.Status], GetStatusesError>
	
	var latestTweet: ESTwitter.Status?

	private static let timeout: TimeInterval = 15.0
	private static let accountStore: ACAccountStore = ACAccountStore()
	private static let accountType: ACAccountType = TwitterController.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
	private static let accountOptions:[NSObject:AnyObject]? = nil
	
	private static let APINotReadyError = SNSController.AuthenticationError.NotReady(service: .Twitter, description: "Twitter API is not ready.")
	private static let APINotReadyNSError = NSError(domain: APINotReadyError.localizedDescription, code: 0, userInfo: [NSLocalizedDescriptionKey:APINotReadyError.localizedDescription])

	private static let twitterCallbackUrl = URL(string: "https://ez-net.jp/")!
	
	private enum AutoVerifyingQueueMessage : MessageTypeIgnoreInQuickSuccession {
	
		case RequestVerification;
		
		fileprivate func messageBlocked() {

			NSLog("Ignoring duplicated `Request Verification` message.")
		}
		
		fileprivate func messageQueued() {
			
			NSLog("queued")
		}
	}
	
	private var autoVerifyingNow: Bool = false
	private var autoVerifyingQueue:MessageQueue<AutoVerifyingQueueMessage>!
	
	var account: Account? {
		
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
	
	func isMyTweet(status: ESTwitter.Status) -> Bool {
		
		guard let account = self.account else {
			
			return false
		}
		
		return account.username == status.user.screenName
	}
	
	private lazy var api: Swifter! = {
		
		guard let account = self.account else {
			
			return nil
		}
		
		switch account {
			
		case let .token(token, tokenSecret, _):
			
			NSLog("🐋 Instantiate Twitter API using Token.")
			
			return Swifter(consumerKey: APIKeys.Twitter.consumerKey, consumerSecret: APIKeys.Twitter.consumerSecret, oauthToken: token, oauthTokenSecret: tokenSecret)
		}
	}()
	
	var credentialsVerified:Bool {
		
		return effectiveUserInfo != nil
	}
	
	private(set) var effectiveUserInfo:UserInfo? {
		
		willSet {
			
			self.willChangeValue(forKey: "credentialsVerified")
			self.willChangeValue(forKey: "canPost")
		}
		
		didSet {
			
			self.didChangeValue(forKey: "credentialsVerified")
			self.didChangeValue(forKey: "canPost")
		}
	}
 
	private init(account: Account?) {
		
		self.account = account
		self.effectiveUserInfo = nil
		
		super.init()
		
		self.autoVerifyingQueue = MessageQueue<AutoVerifyingQueueMessage>(identifier: "\(Self.self)", executionQueue: DispatchQueue.main, processingInterval: 5.0) { message in

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
	
		let authorizationSucceeded: Swifter.TokenSuccessHandler = { accessToken, response in
			
			NSLog("This change is no effect on the current account.")
		}
		
		let authorizationFailed: Swifter.FailureHandler = { error in
			
			self.clearEffectiveUserInfo()
			self.showWarningAlert(withTitle: "Twitter Account is invalid.", message: "Your twitter account setting may be changed by OS. Please check your settings in Internet Account preferences pane.")
		}

		#warning("ここのコードが意味をなしていないはず。")
		api.authorize(withCallback: Self.twitterCallbackUrl, success: authorizationSucceeded, failure: authorizationFailed)
	}
	
	var canPost:Bool {
		
		return self.credentialsVerified
	}
	
	func clearEffectiveUserInfo() {
		
		self.effectiveUserInfo = nil
		
		Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
	}

	@discardableResult
	func verifyCredentialsIfNeed() -> Bool {
		
		DebugTime.print("📮 Passed verify-credentials #1")
		return self.verifyCredentialsIfNeed(callback: verifyCredentialsBasicErrorReportCallback)
	}
	
	@discardableResult
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
		self.verifyCredentials(callback: callback)

		DebugTime.print("📮 Passed verify-credentials #5")
		return true
	}
	
	private func verifyCredentialsBasicErrorReportCallback(result:VerifyResult) -> Void {
		
		DebugTime.print("📮 Passed verify-credentials #11")
		switch result {
			
		case .success:
			DebugTime.print("📮 Passed verify-credentials #12")
			NSLog("Twitter credentials verified successfully. (\(NSApp.twitterController.effectiveUserInfo?.username))")
			
		case .failure(let error):
			DebugTime.print("📮 Passed verify-credentials #13")
			self.showErrorAlert(withTitle: "Failed to verify credentials", message: "\(error.localizedDescription) (\(NSApp.twitterController.effectiveUserInfo?.username))")
		}
	}
	
	func verifyCredentials() {
	
		self.verifyCredentials(callback: self.verifyCredentialsBasicErrorReportCallback)
	}
	
	func verifyCredentials(callback: (VerifyResult)->Void) {
		
		DebugTime.print("📮 Passed verify-credentials #6")

		guard let api = self.api else {
		
			callback(VerifyResult.failure(TwitterController.APINotReadyNSError))
			return
		}
		
		DebugTime.print("📮 Passed verify-credentials #7")
		api.authorize(withCallback: Self.twitterCallbackUrl) { result in
			
			switch result {
				
			case .success(let accessToken, let response):

				DebugTime.print("📮 Passed verify-credentials #9")
				#warning("コンパイルを通すため、ダミーのユーザー名と識別子を入れておきます。")
				self.effectiveUserInfo = UserInfo(username: "username", id: "userId")
				callback(VerifyResult.success(()))

				Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: self.credentialsVerified, username: self.effectiveUserInfo?.username).post()

				
			case .failure(let error):
				
				DebugTime.print("📮 Passed verify-credentials #10")
				self.effectiveUserInfo = nil
				callback(VerifyResult.failure(error as NSError))

				Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: self.credentialsVerified, username: self.effectiveUserInfo?.username).post()
			}
		}
	}

	func post(container:PostDataContainer, latitude: Double? = nil, longitude: Double? = nil, placeID: Double? = nil, displayCoordinates: Bool? = nil, trimUser: Bool? = nil, callback:(PostStatusUpdateResult)->Void) throws {
		
		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
		
		guard let api = self.api else {
			
			DebugTime.print("📮 Twitter API for Verification is not ready ... #3.1.0")
			throw TwitterController.APINotReadyError
		}
		
		guard self.credentialsVerified else {
			
			DebugTime.print("📮 Verification failure ... #3.1.1")
			throw SNSController.AuthenticationError.CredentialsNotVerified
		}

		DebugTime.print("📮 Try posting by Twitter ... #3.2")
		
		api.postTweet(container: container, inReplyToStatusID: nil, coordinate: (lat: latitude, long: longitude) as? (lat: Double, long: Double), autoPopulateReplyMetadata: nil, excludeReplyUserIds: nil, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, mediaIDs: [], attachmentURL: nil, tweetMode: .default) { result in
			
			DebugTime.print("📮 Posted by Twitter ... #3.2.1")

			switch result {
				
			case .success(let json):
				#warning("ここで 'status' を受け取っていた。まずはコンパイルを通すため nil を設定する。")
				self.latestTweet = nil
				#warning("ここで 'status.text' を保存していた。")
				callback(PostStatusUpdateResult.success(json.string!))

			case .failure(let error):
				#warning("ひとまず未知のエラーを報告しておきます。")
				callback(PostStatusUpdateResult.failure(SNSController.PostError.Unexpected(error as NSError)))
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
			throw SNSController.AuthenticationError.CredentialsNotVerified
		}
		
		DebugTime.print("📮 Try posting by Twitter ... #3.2")
		
		#warning("コンパイルを通すために、まずは `image` ではなく空のデータを渡しておきます。")
		api.postMedia(container: container, data: Data(), additionalOwners: nil) { result in
			
			DebugTime.print("📮 Posted by Twitter ... #3.2.1")
			
			switch result {
				
			case .success(let json):

				#warning("ここで以前は `mediaIDs` が渡ってきました。")
				#warning("引数でメディア ID を渡す必要がありますが、いったん保留します。")
//				container.setTwitterMediaIDs(mediaIDs)
				callback(PostResult.Success(container))
				
			case .failure(let error):
				
				container.setError(error: .FailedToUploadGistCapture(image, description: error.localizedDescription))
				callback(PostResult.Failure(container))
			}
		}
	}
	
	func getStatusesWithQuery(query:String, since:String?, callback:(GetStatusesResult)->Void) {
		
		api.searchTweet(using: query, geocode: nil, lang: nil, locale: nil, resultType: "mixed", count: 50, until: nil, sinceID: since, maxID: nil, includeEntities: true, callback: nil, tweetMode: .default) { result in
			
			switch result {
				
			case .success(let (json, searchMetaData)):

				#warning("変更前は (`query: [String:Any], resultData: [AnyObject]! が得られていた。")
				DebugTime.print("Get Statuses : \(query)\n\(json)")
				
				do {

					#warning("コンパイルを通すため、従来の `resultData` を渡さずに、いったん空データを渡している。")
					let data = Data()
					let status = try jsonDecoder.decode([ESTwitter.Status].self, from: data)
					
					callback(GetStatusesResult.success(status))
				}
				catch let error as DecodingError {
					
					let error = GetStatusesError(type: .DecodeResultError, reason: error.localizedDescription)

					callback(GetStatusesResult.failure(error))
				}
				catch let error as NSError {
					
					let error = GetStatusesError(type: .UnexpectedError, reason: error.localizedDescription)

					callback(GetStatusesResult.failure(error))
				}

			case .failure(let error):
				
				#warning("まずは無意味なエラーを設定して、コンパイルを通します。")
				let code = STTwitterTwitterErrorCode.internalError
//				let code = STTwitterTwitterErrorCode(rawValue: error.code)!
				let reason = error.localizedDescription
				
				let error = GetStatusesError(code: code, reason: reason)
				
				callback(GetStatusesResult.failure(error))
			}
		}
	}
}

extension TwitterController {

	typealias RequestAccessResult = Result<Void, NSError>
	
	struct UserInfo {
	
		var username:String
		var id:String
	}
	
	static func requestAccessToAccounts(completion: (RequestAccessResult) -> Void) {
		
		TwitterController.accountStore.requestAccessToAccounts(with: self.accountType, options: self.accountOptions) { granted, error in
			
			if granted {
				
				completion(RequestAccessResult.success(()))
			}
			else {
				
				completion(RequestAccessResult.failure((error as NSError?) ?? NSError(domain: "Not Permitted", code: 0, userInfo: nil)))
			}
		}
	}
	
	static func getAccounts() -> [ACAccount] {
		
		guard let accounts = self.accountStore.accounts(with: self.accountType) as? [ACAccount] else {
			
			return []
		}
		
		return accounts
	}
	
	static func getAccount(identifier:String) -> ACAccount? {
		
		return self.accountStore.account(withIdentifier: identifier)
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

extension TwitterController : LatestTweetManageable {
	
	func resetLatestTweet() {
		
		self.latestTweet = nil
	}
}

extension TwitterController : STTwitterAPIOSProtocol {
	
	func twitterAPI(twitterAPI: STTwitterAPI!, accountWasInvalidated invalidatedAccount: ACAccount!) {
		
		NSLog("Detected OS Account Store change.")
		self.autoVerifyingQueue.send(message: .RequestVerification)
	}
}

extension STTwitterAPI {
	
	typealias MediaID = String
	typealias VerifyCredentialsResult = Result<(username:String,userId:String),NSError>
	typealias PostStatusUpdateResult = Result<ESTwitter.Status, SNSController.PostError>
	typealias PostMediaUploadResult = Result<[STTwitterAPI.MediaID],NSError>

	func postMediaUpload(container:PostDataContainer, image:NSImage, callback:(PostMediaUploadResult)->Void) {
	
		DebugTime.print("📮 Try uploading image for using twitter ... #3.3.3.1")
		
		let data = image.tiffRepresentation!
		let bitmap = NSBitmapImageRep(data: data)!
		let mediaData = bitmap.representation(using: .png, properties: [.interlaced : NSNumber(value: true)])!
		
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
			
			do {
				
				try container.postedToTwitter(postedRawStatus: objects)

				let postedStatus = container.twitterState.postedStatus!
				
				DebugTime.print("📮 A status posted successfully (\(postedStatus))... #3.3.1")
				callback(PostStatusUpdateResult(value: postedStatus))
			}
			catch let PostDataError.TwitterRawObjectsParseError(rawObjects) {
				
				DebugTime.print("📮 A status posted successfully but failed to parse the tweet. (\(rawObjects))... #3.3.1.2")
				callback(PostStatusUpdateResult(error: .SystemError("A tweet posted successfully but failed to parse the tweet.")))
				
				#if DEBUG
					// Re-parse for step debug.
				let jsonString = debugString(fromJSONObject: rawObjects)
					print("DEBUG JSON String\n\(jsonString)")
					let _ = try? decodeValue(rawObjects) as ESTwitter.Status
				#endif
			}
			catch {
				
				fatalError("Unexpected Error (\(type(of: error))) : \(error)")
			}
		}
		
		let tweetFailed = { (error: NSError!) -> Void in
			
			DebugTime.print("📮 Failed to post a status with failure (\(error)) ... #3.3.2")
			
			var postError: SNSController.PostError {

				return SNSController.PostError(twitterError: error)
			}
			
			callback(PostStatusUpdateResult(error: postError))
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
		
		DispatchQueue.main.async {

			DebugTime.print("📮 Start verifying ... #3.4.1")
			
			self.verifyCredentialsWithUserSuccessBlock(verifySucceeded, errorBlock: verifyFailed)
		}
	}
}

extension SNSController.PostError {
	
	init(twitterError error: NSError) {
		
		var errorCode: Int {
			
			return error.code
		}
		
		var errorMessage: String {
			
			return error.localizedDescription
		}
		
		switch errorCode {
			
		case 186:
			self = .FailedToPostTweet(errorMessage)

		default:
			self = .FailedToPostTweet("\(errorMessage) (\(errorCode))")
		}
	}
}
