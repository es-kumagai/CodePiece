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

@objcMembers
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

	fileprivate static let twitterCallbackUrl = URL(string: "\(SwifterScheme.scheme)://twitter")!
	
	private enum AutoVerifyingQueueMessage : MessageTypeIgnoreInQuickSuccession {
	
		case RequestVerification;
		
		fileprivate func messageBlocked() {

			NSLog("Ignoring duplicated `Request Verification` message.")
		}
		
		fileprivate func messageQueued() {
			
			NSLog("queued")
		}
	}
	
//	private var autoVerifyingNow: Bool = false
//	private var autoVerifyingQueue: MessageQueue<AutoVerifyingQueueMessage>!
	
	var account: Account? {
		
		didSet {
			
			NSApp.settings.account.twitterAccount = self.account
			NSApp.settings.saveTwitterAccount()

//			self.api = nil
//			self.clearEffectiveUserInfo()
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
	
	private var swifter: Swifter?
	
	var api: Swifter! {
		
		if swifter == nil {
			
			switch account {
		
			case let .token(token: token, tokenSecret: tokenSecret, screenName: _):
				NSLog("🐋 Instantiate Twitter API using Token.")
				swifter = Swifter(consumerKey: APIKeys.Twitter.consumerKey, consumerSecret: APIKeys.Twitter.consumerSecret, oauthToken: token, oauthTokenSecret: tokenSecret)
			
			case .none:
				swifter = Swifter(consumerKey: APIKeys.Twitter.consumerKey, consumerSecret: APIKeys.Twitter.consumerSecret)
			}
		}

		return swifter
	}
	
	func resetAuthentication() {
		
		swifter = nil
		account = nil
		
		Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
	}
	
//	var credentialsVerified:Bool {
//		
//		return effectiveUserInfo != nil
//	}
	
//	private(set) var effectiveUserInfo:UserInfo? {
//
//		willSet {
//
//			self.willChangeValue(forKey: "credentialsVerified")
//			self.willChangeValue(forKey: "canPost")
//		}
//
//		didSet {
//
//			self.didChangeValue(forKey: "credentialsVerified")
//			self.didChangeValue(forKey: "canPost")
//		}
//	}
 
	private init(account: Account?) {
		
		self.account = account
//		self.effectiveUserInfo = nil
		
		super.init()
		
//		self.autoVerifyingQueue = MessageQueue<AutoVerifyingQueueMessage>(identifier: "\(Self.self)", executionQueue: DispatchQueue.main, processingInterval: 5.0) { message in
//
//			switch message {
//
//			case .RequestVerification:
//				self.autoVerifyingAction()
//			}
//		}
//
//		self.autoVerifyingQueue.start()
	}
	
	convenience override init() {
	
		self.init(account: NSApp.settings.account.twitterAccount)
	}
	
//	private func autoVerifyingAction() {
//
//		guard !self.autoVerifyingNow else {
//
//			return
//		}
//
//		guard self.credentialsVerified else {
//
//			NSLog("This change is no effect on the current account because the account's credentials is not verifyed yet.")
//			return
//		}
//
//		self.autoVerifyingNow = true
//
//		let authorizationSucceeded: Swifter.TokenSuccessHandler = { accessToken, response in
//
//			NSLog("This change is no effect on the current account.")
//
//			#warning("ここに処理を置くのが正しいかどうかを要確認。そもそも Effective User Info が必要かどうかを検討する必要あり。")
//			if let accessToken = accessToken {
//
//				self.effectiveUserInfo = TwitterController.UserInfo(username: accessToken.screenName!, id: accessToken.userID!)
//			}
//		}
//
//		let authorizationFailed: Swifter.FailureHandler = { error in
//
//			self.clearEffectiveUserInfo()
//			self.showWarningAlert(withTitle: "Twitter Account is invalid.", message: "Your twitter account setting may be changed by OS. Please check your settings in Internet Account preferences pane.")
//		}
//
//		#warning("ここのコードが意味をなしていないはず。")
//		api.authorize(withCallback: Self.twitterCallbackUrl, success: authorizationSucceeded, failure: authorizationFailed)
//	}
	
	var canPost:Bool {
		
		return self.readyToUse
	}
	
//	func clearEffectiveUserInfo() {
//
//		self.effectiveUserInfo = nil
//
//		Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: false, username: nil).post()
//	}

//	@discardableResult
//	func verifyCredentialsIfNeed() -> Bool {
//
//		DebugTime.print("📮 Passed verify-credentials #1")
//		return self.verifyCredentialsIfNeed(callback: verifyCredentialsBasicErrorReportCallback)
//	}
	
//	@discardableResult
//	func verifyCredentialsIfNeed(callback: @escaping (VerifyResult)->Void) -> Bool {
//
//		DebugTime.print("📮 Passed verify-credentials #2")
//		guard self.readyToUse else {
//
//			NSLog("Credentials verification skipped because it is not ready to use Twitter.")
//			return false
//		}
//
//		DebugTime.print("📮 Passed verify-credentials #3")
//		guard !self.credentialsVerified else {
//
//			NSLog("Credentials already verifyed.")
//			return false
//		}
//
//		DebugTime.print("📮 Passed verify-credentials #4")
//		self.verifyCredentials(callback: callback)
//
//		DebugTime.print("📮 Passed verify-credentials #5")
//		return true
//	}
	
//	private func verifyCredentialsBasicErrorReportCallback(result:VerifyResult) -> Void {
//
//		DebugTime.print("📮 Passed verify-credentials #11")
//		switch result {
//
//		case .success:
//			DebugTime.print("📮 Passed verify-credentials #12")
//			NSLog("Twitter credentials verified successfully. (\(NSApp.twitterController.effectiveUserInfo?.username))")
//
//		case .failure(let error):
//			DebugTime.print("📮 Passed verify-credentials #13")
//			self.showErrorAlert(withTitle: "Failed to verify credentials", message: "\(error.localizedDescription) (\(NSApp.twitterController.effectiveUserInfo?.username))")
//		}
//	}
	
//	func verifyCredentials() {
//
//		self.verifyCredentials(callback: self.verifyCredentialsBasicErrorReportCallback)
//	}
//
//	func verifyCredentials(callback: @escaping (VerifyResult)->Void) {
//
//		DebugTime.print("📮 Passed verify-credentials #6")
//
//		guard let api = self.api else {
//
//			callback(VerifyResult.failure(TwitterController.APINotReadyNSError))
//			return
//		}
//
//		DebugTime.print("📮 Passed verify-credentials #7")
//		api.authorize { result in
//
//			switch result {
//
//			case .success(let accessToken, let username, let userId, let response):
//
//				DebugTime.print("📮 Passed verify-credentials #9")
//
//				self.effectiveUserInfo = UserInfo(username: username, id: userId)
//				callback(VerifyResult.success(()))
//
//				Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: self.credentialsVerified, username: self.effectiveUserInfo?.username).post()
//
//
//			case .failure(let error):
//
//				DebugTime.print("📮 Passed verify-credentials #10")
//				self.effectiveUserInfo = nil
//				callback(VerifyResult.failure(error as NSError))
//
//				Authorization.TwitterAuthorizationStateDidChangeNotification(isValid: self.credentialsVerified, username: self.effectiveUserInfo?.username).post()
//			}
//		}
//	}

	func post(container:PostDataContainer, latitude: Double? = nil, longitude: Double? = nil, placeID: Double? = nil, displayCoordinates: Bool? = nil, trimUser: Bool? = nil, callback: @escaping (PostStatusUpdateResult)->Void) throws {
		
		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
		
		guard let api = self.api else {
			
			DebugTime.print("📮 Twitter API for Verification is not ready ... #3.1.0")
			throw TwitterController.APINotReadyError
		}
		
		guard self.readyToUse else {
			
			DebugTime.print("📮 Verification failure ... #3.1.1")
			throw SNSController.AuthenticationError.CredentialsNotVerified
		}

		DebugTime.print("📮 Try posting by Twitter ... #3.2")
		
		api.postTweet(container: container, inReplyToStatusID: nil, coordinate: (lat: latitude, long: longitude) as? (lat: Double, long: Double), autoPopulateReplyMetadata: nil, excludeReplyUserIds: nil, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, mediaIDs: [], attachmentURL: nil, tweetMode: .default) { result in
			
			DebugTime.print("📮 Posted by Twitter ... #3.2.1")

			switch result {
				
			case .success(let status):

				self.latestTweet = status
				callback(PostStatusUpdateResult.success(status.text))

			case .failure(let error):
				callback(.failure(error))

//				#warning("ひとまず未知のエラーを報告しておきます。")
//				callback(PostStatusUpdateResult.failure(SNSController.PostError.Unexpected(error as NSError)))
			}
		}
	}
	
	func postMedia(container:PostDataContainer, image:NSImage, callback: @escaping (PostResult)->Void) throws {
		
		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
		
		guard let api = self.api else {
			
			DebugTime.print("📮 Twitter API for Verification is not ready ... #3.1.0")
			throw TwitterController.APINotReadyError
		}
		
		guard self.readyToUse else {
			
			DebugTime.print("📮 Verification failure ... #3.1.1")
			throw SNSController.AuthenticationError.CredentialsNotVerified
		}
		
		DebugTime.print("📮 Try posting by Twitter ... #3.2")
		
		api.postMedia(container: container, image: image, additionalOwners: nil) { result in
			
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
	
	func getStatusesWithQuery(query:String, since:String?, callback: @escaping (GetStatusesResult) -> Void) {
		
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
	
//	static func requestAccessToAccounts(completion: @escaping (RequestAccessResult) -> Void) {
//		
//		TwitterController.accountStore.requestAccessToAccounts(with: self.accountType, options: self.accountOptions) { granted, error in
//			
//			if granted {
//				
//				completion(RequestAccessResult.success(()))
//			}
//			else {
//				
//				completion(RequestAccessResult.failure((error as NSError?) ?? NSError(domain: "Not Permitted", code: 0, userInfo: nil)))
//			}
//		}
//	}
	
//	static func getAccounts() -> [ACAccount] {
//
//		guard let accounts = self.accountStore.accounts(with: self.accountType) as? [ACAccount] else {
//
//			return []
//		}
//
//		return accounts
//	}
//
//	static func getAccount(identifier:String) -> ACAccount? {
//
//		return self.accountStore.account(withIdentifier: identifier)
//	}
//
//	static func getSingleAccount() -> ACAccount? {
//
//		let accounts = self.getAccounts()
//
//		if accounts.count == 1 {
//
//			return accounts.first!
//		}
//		else {
//
//			return nil
//		}
//	}
	
	func authorize(handler: @escaping (Swifter.AutorizationResult) -> Void) {

		#warning("effectiveUserInfo を廃止した都合で、副作用のない Wrapper になっている")
		api.authorize { result in

			switch result {
				
			case let .success(accessToken, userName, userId, response):
//				if let accessToken = accessToken {
//
//					self.effectiveUserInfo = TwitterController.UserInfo(username: accessToken.screenName!, id: accessToken.userID!)
//				}
				
				handler(.success((accessToken, userName: userName, userId: userId, response)))
				
			case .failure(let error):
				handler(.failure(error))
			}
		}
	}
}

extension TwitterController : LatestTweetManageable {
	
	func resetLatestTweet() {
		
		self.latestTweet = nil
	}
}

extension Swifter {
		
    func postMedia(container: PostDataContainer,
				   image: NSImage,
                   additionalOwners: UsersTag? = nil,
				   handler: @escaping (PostMediaResult) -> Void) {
		
		let successHandler: SuccessHandler = { json in
			
			DebugTime.print("📮 A thumbnail media posted ... #3.3.3.2.1")
			
			#warning("ここで json から MediaID を取得します。")
			NSLog("%@", json.description)
			let mediaID = "0"
			
			container.setTwitterMediaIDs(mediaID)
			
			handler(.success([mediaID]))
		}
		
		let failureHandler: FailureHandler = { error in
			
			if let error = error as? SwifterError {

				handler(.failure(.FailedToPostTweet(error.message)))
			}
			else {
				
				DebugTime.print("📮 Failed to updload a thumbnail media ... #3.3.3.2.2")
				handler(.failure(.Unexpected(error)))
			}
		}
		

		DebugTime.print("📮 Try uploading image for using twitter ... #3.3.3.1")
		
		let data = image.tiffRepresentation!
		let bitmap = NSBitmapImageRep(data: data)!
		let mediaData = bitmap.representation(using: .png, properties: [.interlaced : NSNumber(value: true)])!
		
		let tweetProgress = { (bytes:Int64, processedBytes:Int64, totalBytes:Int64) -> Void in
			
			DebugTime.print("bytes:\(bytes), processed:\(processedBytes), total:\(totalBytes)")
		}
				
		DebugTime.print("📮 Try posting by API ... #3.3.3.2")
		postMedia(mediaData, additionalOwners: additionalOwners, success: successHandler, failure: failureHandler)
	}
	
	func postTweet(container: PostDataContainer,
					inReplyToStatusID: String? = nil,
					coordinate: (lat: Double, long: Double)? = nil,
					autoPopulateReplyMetadata: Bool? = nil,
					excludeReplyUserIds: Bool? = nil,
					placeID: Double? = nil,
					displayCoordinates: Bool? = nil,
					trimUser: Bool? = nil,
					mediaIDs: [MediaID] = [],
					attachmentURL: Foundation.URL? = nil,
					tweetMode: TweetMode = .default,
					handler: @escaping (PostTweetResult) -> Void) {
	
		let successHandler: SuccessHandler = { json in
			
			do {
				
				try container.postedToTwitter(postedRawStatus: json.object!)

				let postedStatus = container.twitterState.postedStatus!
				
				DebugTime.print("📮 A status posted successfully (\(postedStatus))... #3.3.1")
				handler(.success(postedStatus))
			}
			catch let PostDataError.TwitterRawObjectsParseError(rawObjects) {
				
				DebugTime.print("📮 A status posted successfully but failed to parse the tweet. (\(rawObjects))... #3.3.1.2")
				handler(.failure(.SystemError("A tweet posted successfully but failed to parse the tweet.")))
				
				#if DEBUG
					// Re-parse for step debug.
				let jsonString = rawObjects.description
					print("DEBUG JSON String\n\(jsonString)")
				let jsonData = jsonString.data(using: .utf8)!
				
				let _ = try! JSONDecoder().decode(ESTwitter.Status.self, from: jsonData)
				#endif
			}
			catch {
				
				fatalError("Unexpected Error (\(type(of: error))) : \(error)")
			}
		}
		
		let failureHandler: FailureHandler = { error in
			
			DebugTime.print("📮 Failed to post a status with failure (\(error)) ... #3.3.2")
			
			var postError: SNSController.PostError {

				switch error {
					
				case let error as SwifterError:
					return SNSController.PostError.FailedToPostTweet(error.message)
					
				default:
					return SNSController.PostError.FailedToPostTweet(error.localizedDescription)
				}
			}
			
			handler(.failure(postError))
		}
				
		
		DebugTime.print("📮 Try to post a status by Twitter ... #3.3")

		postTweet(status: "DUMMY", inReplyToStatusID: inReplyToStatusID, coordinate: coordinate, autoPopulateReplyMetadata: autoPopulateReplyMetadata, excludeReplyUserIds: excludeReplyUserIds, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, mediaIDs: mediaIDs, attachmentURL: attachmentURL, tweetMode: tweetMode, success: successHandler, failure: failureHandler)

		DebugTime.print("📮 Post requested by API ... #3.3.4")

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
			
			handler(.success((json, searchMetaData)))
		}
		
		let failureHandler: FailureHandler = { error in
			
			handler(.failure(error))
		}
		
		searchTweet(using: query, geocode: geocode, lang: lang, locale: locale, resultType: resultType, count: count, until: until, sinceID: sinceID, maxID: maxID, includeEntities: includeEntities, callback: callback, tweetMode: tweetMode, success: successHandler, failure: failureHandler)
	}
	
	fileprivate func authorize(handler: @escaping (AutorizationResult) -> Void) {

		let successHandler: TokenSuccessHandler = { accessToken, response in

			#warning("ここで Username と UserId を取得します。")
			let username = "Dummy Name"
			let userId = "Dummy ID"
			
			DebugTime.print("📮 Verification successfully (Name:\(username), ID:\(userId)) ... #3.4.2")

			handler(.success((accessToken, username, userId, response)))
		}

		let failureHandler: FailureHandler = { error in
			
			DebugTime.print("📮 Verification failed with error '\(error.localizedDescription)' ... #3.4.2")
			handler(.failure(error))
		}
		
		DebugTime.print("📮 Try to verify credentials ... #3.4")
		
		DispatchQueue.main.async {

			DebugTime.print("📮 Start verifying ... #3.4.1")
			
			self.authorize(withCallback: TwitterController.twitterCallbackUrl, success: successHandler, failure: failureHandler)
		}
	}
}

extension SNSController.PostError {
	
//	init(twitterError error: NSError) {
//
//		var errorCode: Int {
//
//			return error.code
//		}
//
//		var errorMessage: String {
//
//			return error.localizedDescription
//		}
//
//		switch errorCode {
//
//		case 186:
//			self = .FailedToPostTweet(errorMessage)
//
//		default:
//			self = .FailedToPostTweet("\(errorMessage) (\(errorCode))")
//		}
//	}
}
