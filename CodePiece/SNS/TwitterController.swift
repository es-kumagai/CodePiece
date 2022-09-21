//
//  TwitterController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import struct Foundation.URL
import class AppKit.NSImage

import class AppKit.NSBitmapImageRep

import ESTwitter
import ESGists
import Ocean
import Swim
import CodePieceCore

private let jsonDecoder = JSONDecoder()

// FIXME: TwitterController は AlertDisplayable であるべきではなそうなので、別のビューコントローラーが持つようにした。
@objcMembers
@MainActor
final class TwitterController : NSObject, AlertDisplayable, NotificationObservable {
	
	private(set) var latestTweet: ESTwitter.Status?
	let notificationHandlers = Notification.Handlers()

	private static let timeout: TimeInterval = 15.0
//	private static let accountStore: ACAccountStore = ACAccountStore()
//	private static let accountType: ACAccountType = TwitterController.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
	private static let accountOptions: [NSObject : AnyObject]? = nil
	
	private static let APINotReadyError = SNSController.AuthenticationError.notReady(service: .twitter, description: "Twitter API is not ready.")
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
	
	var token: Token? {

		NSApp.settings.account.twitterToken
	}
	
	func updateToken(_ token: Token?) {

		NSApp.settings.account.twitterToken = token
		NSApp.settings.saveTwitterAccount()
	}
	
	var readyToUse: Bool {
		
		hasToken && credentialsVerified
	}
	
	var hasToken: Bool {
	
		token != nil
	}
	
	func isMyTweet(status: ESTwitter.Status) async -> Bool {
		
		guard let token = token else {
			
			return false
		}
		
		return token.screenName == status.user.screenName
	}
	
	private var api: ESTwitter.API!
	
	func prepareApi() async {
		
		guard let consumerKey = APIKeys.Twitter.consumerKey, let consumerSecret = APIKeys.Twitter.consumerSecret else {
			
			fatalError("You MUST specify id and key in `APIKeys.Twitter`.")
		}
		
		if let token = token {
		
			api = await ESTwitter.API(consumerKey: consumerKey, tokenSecret: consumerSecret, oauthToken: token.key, oauthTokenSecret: token.secret)
			DebugTime.print("API is prepared with token.")
		}
		else {

			api = await ESTwitter.API(consumerKey: consumerKey, tokenSecret: consumerSecret)
			DebugTime.print("API is prepared without token.")
		}
	}

	func resetToken() async {

		let previousScreenName = token?.screenName

		updateToken(nil)
		NSApp.settings.resetTwitterAccount(saveFinally: true)
		
		AuthorizationStateDidChangeNotification(isCredentialVerified: false, screenName: previousScreenName).post()
	}
	
	func resetAuthentication() async {
		
		do {

			try await api.reset()
			
			await resetToken()
			AuthorizationResetSucceededNotification().post()
		}
		catch let error as APIError {
			
			AuthorizationResetFailureNotification(error: error).post()
		}
		catch {
			
			AuthorizationResetFailureNotification(error: .unexpected(error)).post()
		}
	}
	
	var credentialsVerified: Bool {
		
		guard let api = api else {
		
			return false
		}
		
		return api.isCredentialVerified
	}
	
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
 
//	private init(account: Account?) {
	override init() {
		
		super.init()
//		self.account = account
//		self.effectiveUserInfo = nil
		
//		super.init()
		
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
		
		observe(AuthorizationResetFailureNotification.self) { [unowned self] notification in

			showErrorAlert(withTitle: "Failed to reset authorization.", message: notification.error.localizedDescription)
		}
		
		observe(ReachabilityController.ReachabilityChangedNotification.self) { [unowned self] _ in
			
			await verifyCredentialsIfNeed()
		}
	}
	
//	convenience override init() {
//
//		self.init(account: NSApp.settings.account.twitterAccount)
//	}
	
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
	
	dynamic var canPost: Bool {
		
		readyToUse
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
	
	func verifyCredentialsIfNeed() async {

		DebugTime.print("📮 Passed verify-credentials #2")
		guard hasToken else {

			NSLog("Twitter controller has not token. Skip verifying the credentials.")
			return
		}

		DebugTime.print("📮 Passed verify-credentials #3")
		guard !credentialsVerified else {

			NSLog("Credentials already verifyed in Twitter.")
			return
		}

		DebugTime.print("📮 Passed verify-credentials #4")
		await verifyCredentials()

		DebugTime.print("📮 Passed verify-credentials #5")
	}
	
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
	func verifyCredentials() async {

		DebugTime.print("📮 Passed verify-credentials #6")

		guard hasToken else {

			CredentialsVerifyFailureNotification(error: .notReady).post()
			return
		}

		DebugTime.print("📮 Passed verify-credentials #7")
		
		do {

			try await api.verifyCredentials()
			
			DebugTime.print("📮 Passed verify-credentials #9")
			
			let isCredentialVerified = api.isCredentialVerified
			let screenName = token?.screenName
			
			AuthorizationStateDidChangeNotification(isCredentialVerified: isCredentialVerified, screenName: screenName).post()
		}
		catch let error as APIError {
			
			DebugTime.print("📮 Passed verify-credentials #10")
			switch error {
				
			case .responseError(401, message: _):
				await resetToken()
				AuthorizationStateInvalidNotification().post()
				AuthorizationStateDidChangeWithErrorNotification(error: .apiError(error)).post()

			case .responseError(code: 220, message: _):
				// Your credentials do not allow access to this resource
				await resetToken()
				AuthorizationStateInvalidNotification().post()
				AuthorizationStateDidChangeWithErrorNotification(error: .apiError(error)).post()
				
			case .offline:
				AuthorizationStateDidChangeWithErrorNotification(error: .apiError(error)).post()
				
			default:
				AuthorizationStateDidChangeWithErrorNotification(error: .apiError(error)).post()
			}
		}
		catch {
			
			DebugTime.print("📮 Passed verify-credentials #11")
			AuthorizationStateDidChangeWithErrorNotification(error: .unknownError(error)).post()
		}
		
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
	}

//	func post(container:PostDataContainer, latitude: Double? = nil, longitude: Double? = nil, placeID: Double? = nil, displayCoordinates: Bool? = nil, trimUser: Bool? = nil, callback: @escaping (PostStatusUpdateResult)->Void) throws {
//
//		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
//
////		guard api.isAuthorized else {
////
////			DebugTime.print("📮 Twitter API for Verification is not ready ... #3.1.0")
////			throw TwitterController.APINotReadyError
////		}
//
//		guard api.isCredentialVerified else {
//
//			DebugTime.print("📮 Verification failure ... #3.1.1")
//			throw SNSController.AuthenticationError.CredentialsNotVerified
//		}
//
//		DebugTime.print("📮 Try posting by Twitter ... #3.2")
//
//		api.postTweet(container: container, inReplyToStatusID: nil, coordinate: (lat: latitude, long: longitude) as? (lat: Double, long: Double), autoPopulateReplyMetadata: nil, excludeReplyUserIds: nil, placeID: placeID, displayCoordinates: displayCoordinates, trimUser: trimUser, mediaIDs: [], attachmentURL: nil, tweetMode: .default) { result in
//
//			DebugTime.print("📮 Posted by Twitter ... #3.2.1")
//
//			switch result {
//
//			case .success(let status):
//
//				self.latestTweet = status
//				callback(PostStatusUpdateResult.success(status.text))
//
//			case .failure(let error):
//				callback(.failure(error))
//
////				#warning("ひとまず未知のエラーを報告しておきます。")
////				callback(PostStatusUpdateResult.failure(SNSController.PostError.Unexpected(error as NSError)))
//			}
//		}
//	}
	
//	func postMedia(container:PostDataContainer, image:NSImage, callback: @escaping (PostResult)->Void) throws {
//
//		DebugTime.print("📮 Verifying credentials of Twitter ... #3.1")
//
//		guard let api = self.api else {
//
//			DebugTime.print("📮 Twitter API for Verification is not ready ... #3.1.0")
//			throw TwitterController.APINotReadyError
//		}
//
//		guard self.readyToUse else {
//
//			DebugTime.print("📮 Verification failure ... #3.1.1")
//			throw SNSController.AuthenticationError.CredentialsNotVerified
//		}
//
//		DebugTime.print("📮 Try posting by Twitter ... #3.2")
//
//		api.postMedia(container: container, image: image, additionalOwners: nil) { result in
//
//			DebugTime.print("📮 Posted by Twitter ... #3.2.1")
//
//			switch result {
//
//			case .success(let json):
//
//				#warning("ここで以前は `mediaIDs` が渡ってきました。")
//				#warning("引数でメディア ID を渡す必要がありますが、いったん保留します。")
////				container.setTwitterMediaIDs(mediaIDs)
//				callback(PostResult.Success(container))
//
//			case .failure(let error):
//
//				container.setError(error: .FailedToUploadGistCapture(image, description: error.localizedDescription))
//				callback(PostResult.Failure(container))
//			}
//		}
//	}
	
//	func getStatusesWithQuery(query:String, since:String?, callback: @escaping (GetStatusesResult) -> Void) {
//
//		api.searchTweet(using: query, geocode: nil, lang: nil, locale: nil, resultType: "mixed", count: 50, until: nil, sinceID: since, maxID: nil, includeEntities: true, callback: nil, tweetMode: .default) { result in
//
//			switch result {
//
//			case .success(let (json, searchMetaData)):
//
//				#warning("変更前は (`query: [String:Any], resultData: [AnyObject]! が得られていた。")
//				DebugTime.print("Get Statuses : \(query)\n\(json)")
//
//				do {
//
//					#warning("コンパイルを通すため、従来の `resultData` を渡さずに、いったん空データを渡している。")
//					let data = Data()
//					let status = try jsonDecoder.decode([ESTwitter.Status].self, from: data)
//
//					callback(GetStatusesResult.success(status))
//				}
//				catch let error as DecodingError {
//
//					let error = GetStatusesError(type: .DecodeResultError, reason: error.localizedDescription)
//
//					callback(GetStatusesResult.failure(error))
//				}
//				catch let error as NSError {
//
//					let error = GetStatusesError(type: .UnexpectedError, reason: error.localizedDescription)
//
//					callback(GetStatusesResult.failure(error))
//				}
//
//			case .failure(let error):
//
//				#warning("まずは無意味なエラーを設定して、コンパイルを通します。")
//				let code = STTwitterTwitterErrorCode.internalError
////				let code = STTwitterTwitterErrorCode(rawValue: error.code)!
//				let reason = error.localizedDescription
//
//				let error = GetStatusesError(code: code, reason: reason)
//
//				callback(GetStatusesResult.failure(error))
//			}
//		}
//	}
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
	
//	func authorize(handler: @escaping (Swifter.AutorizationResult) -> Void) {
//
//		#warning("effectiveUserInfo を廃止した都合で、副作用のない Wrapper になっている")
//		api.authorize { result in
//
//			switch result {
//
//			case let .success(accessToken, userName, userId, response):
////				if let accessToken = accessToken {
////
////					self.effectiveUserInfo = TwitterController.UserInfo(username: accessToken.screenName!, id: accessToken.userID!)
////				}
//
//				handler(.success((accessToken, userName: userName, userId: userId, response)))
//
//			case .failure(let error):
//				handler(.failure(error))
//			}
//		}
//	}
}

//extension TwitterController : LatestTweetManageable {
//	
//	func resetLatestTweet() {
//		
//		self.latestTweet = nil
//	}
//}

extension TwitterController {
		
	func post(image: NSImage, container: PostDataContainer, additionalOwners: API.UsersTag? = nil) async {
		
		let rawData = image.tiffRepresentation!
		let bitmap = NSBitmapImageRep(data: rawData)!
		let mediaData = bitmap.representation(using: .png, properties: [.interlaced : NSNumber(value: true)])!
		
		await post(media: mediaData, container: container, additionalOwners: additionalOwners)
	}
	
	func post(media data: Data, container: PostDataContainer, additionalOwners: API.UsersTag? = nil) async {
		
		DebugTime.print("📮 Try uploading image for using twitter ... #3.3.3.1")
		
		// STTwitter ではメディアアップロードでプログレスを指定できていました。以下はその名残です。
//		let tweetProgress = { (bytes:Int64, processedBytes:Int64, totalBytes:Int64) -> Void in
//
//			DebugTime.print("bytes:\(bytes), processed:\(processedBytes), total:\(totalBytes)")
//		}
				
		do {

			DebugTime.print("📮 Try posting by API ... #3.3.3.2")
			let mediaIDs = try await api.post(media: data, additionalOwners: additionalOwners)
			
			DebugTime.print("📮 A thumbnail media posted ... #3.3.3.2.1")
			await container.setTwitterMediaIDs(mediaIDs: mediaIDs)
		}
		catch {

			DebugTime.print("📮 Failed to updload a thumbnail media ... #3.3.3.2.2")
			
			let error = SNSController.PostError.failedToUploadMedia(reason: "\(error)", state: .postMediaDirectly)
			await container.setError(error)
		}
	}
	
	@available(*, message: "他の箇所ではエラー情報を container に入れるだけで throw していなかったため、ここのような throws が適切かを再考する必要があります。")
	func post(statusUsing container: PostDataContainer) async throws {
	
		DebugTime.print("📮 Try to post a status by Twitter ... #3.3")

		let options = await API.PostOption(from: container)

		do {

			let status = try await api.post(tweet: container.makeDescriptionForTwitter(), options: options)

			await container.postedToTwitter(postedStatus: status)
			
			latestTweet = status
//			let postedStatus = container.twitterState.postedStatus!
			
			DebugTime.print("📮 A status posted successfully (\(status))... #3.3.1")
		}
		catch let error as PostError {
			
			DebugTime.print("📮 Failed to post a status with failure (\(error)) ... #3.3.2")
			
			let error = SNSController.PostError.twitterError(error, state: .postTweetDirectly)
			await container.setError(error)
			
			throw error
		}
		catch {
			
			DebugTime.print("📮 Failed to post a status with unexpected failure (\(error)) ... #3.3.2")
			
			let error = SNSController.PostError.unexpected(error, state: .postTweetDirectly)
			await container.setError(error)
			
			throw error
		}
	}
	
	func search(tweetWith query: API.SearchQuery, options: API.SearchOptions = API.SearchOptions()) async throws -> Statuses {
		
		try await api.search(usingQuery: query.queryString, options: options)
	}
	
	func mentions(options: API.MentionOptions = .init()) async throws -> Statuses {
	
		try await api.mentions(options: options)
	}
	
	func timeline(options: API.TimelineOptions = .init()) async throws -> Statuses {
	
		guard let id = token?.userId else {
			
			throw GetStatusesError.apiError(.notReady)
		}
		
		return try await timeline(of: .id(id), options: options)
	}
	
	func timeline(of user: API.UserSelector, options: API.TimelineOptions = .init()) async throws -> Statuses {
		
		try await api.timeline(of: user, options: options)
	}
	
	func authorize() async {

		DebugTime.print("📮 Try to verify credentials ... #3.4")
		
		DebugTime.print("📮 Start verifying ... #3.4.1")
		
		do {

			let token = try await api.authorize(withCallbackUrl: TwitterController.twitterCallbackUrl)
			
			let screenName = token.screenName
			let userId = token.userId
			
			DebugTime.print("📮 Verification successfully (Name:\(screenName), ID:\(userId)) ... #3.4.2")

			updateToken(token)
			await verifyCredentials()
		}
		catch {
			
			DebugTime.print("📮 Verification failed with error '\(error.localizedDescription)' ... #3.4.2")

			switch error {
				
			case let error as AuthorizationError:
				AuthorizationStateDidChangeWithErrorNotification(error: error).post()

			case let error:
				AuthorizationStateDidChangeWithErrorNotification(error: .unknownError(error)).post()
			}
		}
	}
}
