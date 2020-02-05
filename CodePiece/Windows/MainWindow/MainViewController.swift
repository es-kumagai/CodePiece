//
//  MainViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGists
import Ocean
//import Quartz
import Swim
import ESProgressHUD
import ESTwitter

@objcMembers
final class MainViewController: NSViewController, NotificationObservable {

	enum ReplyToType {
		
		case none
		case latestTweet
		case selectedStatus
	}
	
	var nextReplyToType = ReplyToType.none {
		
		willSet {
			
			willChangeValue(forKey: "canReplyTo")
		}
		
		didSet {
			
			didChangeValue(forKey: "canReplyTo")
		}
	}
	var notificationHandlers = Notification.Handlers()
	
	var twitterController: TwitterController {
		
		return NSApp.snsController.twitter
	}
	
	private var postingHUD: ProgressHUD = ProgressHUD(message: "Posting...", useActivityIndicator: true)
	
	private(set) var latestTweet: ESTwitter.Status?
	private(set) var selectedStatuses = Array<ESTwitter.Status>()
	private(set) var statusForReplyTo: ESTwitter.Status? {
		
		didSet {
			
			if let status = statusForReplyTo {
				
				print("Set 'Reply-To:' \(status.user)")
			}
			else {
				
				print("Reset 'Reply-To:")
			}
		}
	}
	
	@IBOutlet var postButton: NSButton!
	@IBOutlet var hashTagTextField: HashtagTextField!
	
	@IBOutlet var languagePopUpButton: NSPopUpButton!
	@IBOutlet var languagePopUpDataSource: LanguagePopupDataSource!
	
	@IBOutlet var codeTextView: CodeTextView! {
	
		didSet {
			
			codeTextView.font = .codeFont

			// MARK: IB からだと自動書式調整のプロパティを変えても効かないので、ここで調整しています。
			codeTextView.isAutomaticDashSubstitutionEnabled = false
			codeTextView.isAutomaticDataDetectionEnabled = false
			codeTextView.isAutomaticLinkDetectionEnabled = false
			codeTextView.isAutomaticQuoteSubstitutionEnabled = false
			codeTextView.isAutomaticSpellingCorrectionEnabled = false
			codeTextView.isAutomaticTextReplacementEnabled = false
			codeTextView.isContinuousSpellCheckingEnabled = false
		}
	}
	
	@IBOutlet var descriptionTextField: DescriptionTextField!
	@IBOutlet var descriptionCountLabel: NSTextField!
	
	@IBOutlet var codeScrollView: NSScrollView!
	
	@IBOutlet var languageWatermark: WatermarkLabel! {
		
		didSet {
			
			languageWatermark.stringValue = ""
		}
	}
	
	@IBOutlet var hashtagWatermark: WatermarkLabel! {
		
		didSet {
			
			hashtagWatermark.stringValue = ""
		}
	}
	
	var baseViewController: BaseViewController {
		
		return parent as! BaseViewController
	}
	
	var posting: Bool = false {
	
		willSet {
			
			willChangeValue(forKey: "canPost")
		}
		
		didSet {
			
			didChangeValue(forKey: "canPost")
		}
	}
	
	var canPost: Bool {
	
		let conditions = [
			
			!self.posting,
			!self.descriptionTextField.twitterText.isEmpty,
			self.codeTextView.hasCode || !self.descriptionTextField.isReplyAddressOnly
		]
		
		return conditions.meetsAll(of: true)
	}
	
	var selectedLanguage:Language {
		
		return self.languagePopUpButton.selectedItem.flatMap { Language(displayText: $0.title) }!
	}

	var customHashtags: [Hashtag] {
	
		return hashTagTextField.hashtags.sorted()
	}
	
	var customHashtagsExcludeLanguageHashtag: [Hashtag] {

		let languageHashtag = selectedLanguage.hashtag
		let customHashtags = hashTagTextField.hashtags.sorted().filter { $0 != languageHashtag }

		return customHashtags
	}
	
//	var effectiveHashtags: [Hashtag] {
//
//		return effectiveHashtagsExcludeLanguageHashtag + [selectedLanguage.hashtag]
//	}
	
	func terminate(_ sender: Any) {
		
		clearContents()
		saveContents()

		NSApp.terminate(self)
	}

	@IBAction func pushPostButton(_ sender:NSObject?) {
	
		self.saveContents()
		self.postToSNS()
	}
	
	func postToSNS() {

		guard canPost else {
			
			return
		}

		guard NSApp.snsController.canPost else {
		
			self.showErrorAlert(withTitle: "Not ready to post", message: "Please set SNS accounts on the app's preferences. If you'd like to open the preference, type `⌘,`.)")
			return
		}
		
		posting = true
		postingHUD.show()
		
		post { result in
			
			defer {
				
				self.posting = false
				self.postingHUD.hide()
			}
			
			switch result {
				
			case .success(let container):
				PostCompletelyNotification(container: container, postedStatus: container.twitterState.postedStatus, hashtags: self.hashTagTextField.hashtags).post()
				
			case .failure(let error):
				PostFailedNotification(error: error).post()
			}
		}
	}
	
	func post(callback: @escaping (SNSController.PostResult) -> Void) {
		
		DebugTime.print("📮 Try to post ... #1")
		
		NSApp.snsController.post(container: makePostDataContainer()) { container in
			
			
			DebugTime.print("📮 Posted \(container.twitterState.postedStatus?.text ?? "(unknown)") ... #1.1.1")
			
			if container.posted {
				
				switch container.latestError {

				case .some(let error):
					container.setError(.postError(error.descriptionWithoutState, state: .occurred(on: .posted)))
					callback(.success(container))

				case .none:
					callback(.success(container))
				}
			}
			else {
				
				switch container.latestError {
					
				case .some(let error):
					callback(.failure(error))
					
				case .none:
					callback(.failure(.systemError("Unknown error.", state: .unidentifiable)))
				}
			}
		}
	}
	
	func restoreContents() {

		DebugTime.print("Restoring contents in main window.")
		
		NSApp.settings.appState.selectedLanguage.executeIfExists(languagePopUpDataSource.selectLanguage)
		NSApp.settings.appState.hashtags.executeIfExists { hashTagTextField.hashtags = $0 }
		NSApp.settings.appState.description.executeIfExists { descriptionTextField.stringValue = $0 }
		NSApp.settings.appState.code.executeIfExists { codeTextView.string = $0 }
	}
	
	func saveContents() {
		
		DebugTime.print("Saving contents in main window.")
		
		NSApp.settings.appState.selectedLanguage = selectedLanguage
		NSApp.settings.appState.hashtags = hashTagTextField.hashtags
		NSApp.settings.appState.description = descriptionTextField.stringValue
		NSApp.settings.appState.code = codeTextView.string

		NSApp.settings.saveAppState()
	}
		
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		DebugTime.print("Main window loaded.")
		twitterController.prepareApi()
	}
	
	override func viewWillAppear() {
		
		DebugTime.print("Main window will show.")

		super.viewWillAppear()

		restoreContents()
		focusToDefaultControl()
		updateControlsDisplayText()

		clearContents()
		
		observe(notification: PostCompletelyNotification.self) { [unowned self] notification in
			
			let container = notification.container
			
			self.clearContents()
			self.latestTweet = container.twitterState.postedStatus
			self.nextReplyToType = .latestTweet

			self.saveContents()

			if let error = container.latestError {
				
				self.showErrorAlert(withTitle: "Finish posting, but ...", message: "\(error)")
			}
			
			NSLog("Posted completely \(notification.container.twitterState.postedStatus?.text ?? "(unknown)")")
		}
		
		observe(notification: PostFailedNotification.self) { [unowned self] notification in
			
			self.showErrorAlert(withTitle: "Failed to post", message: "\(notification.error)")
		}
		
		observe(notification: LanguagePopupDataSource.LanguageSelectionChanged.self) { [unowned self] notification in
			
			self.updateWatermark()
			self.updateTweetTextCount()
			self.saveContents()
		}
		
		observe(notification: HashtagsDidChangeNotification.self) { [unowned self] notification in

			self.saveContents()
		}
		
		observe(notification: TimelineSelectionChangedNotification.self) { [unowned self] notification in
			
			guard notification.selectedCells.count == 1 else {

				self.selectedStatuses = []
				return
			}

			self.selectedStatuses = notification.selectedCells.compactMap { $0.cell?.item?.status }
			self.nextReplyToType = .selectedStatus
			
			print("Selection Changed : \(self.selectedStatuses.map { "\($0.user.screenName) : \($0.text)" } )")
		}
		
		observe(notification: TimelineReplyToSelectionRequestNotification.self) { [unowned self] notification in
			
			self.setReplyTo(notification)
		}
		
		observe(notification: TwitterController.AuthorizationStateInvalidNotification.self) { [unowned self] notification in
			
			if NSApp.settings.isReady {
			
				DebugTime.print("Authorization State is invalid. Try authenticating.")
				self.twitterController.authorize()
			}
		}
		
		observe(notification: TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			self.withChangeValue(for: "CanPost")
		}

		observe(notification: TwitterController.AuthorizationStateDidChangeWithErrorNotification.self) { [unowned self] notification in

			switch notification.error {

			case .notAuthorized(let message):

				self.showErrorAlert(withTitle: "Failed to authorization", message: message)

			default:
				self.showErrorAlert(withTitle: "Failed to authorization", message: "\(notification.error)")
			}
		}
	}
	
	override func viewDidAppear() {
		
		DebugTime.print("Main window did show.")
		
		super.viewDidAppear()
		
		updateWatermark()
		updateTweetTextCount()

		
		if NSApp.settings.isReady {
			
			twitterController.verifyCredentialsIfNeed()
		}
		else {
			
			if NSApp.environment.showWelcomeBoardOnStartup {
				
				NSApp.showWelcomeBoard()
			}
		}
	}
	
	override func viewWillDisappear() {
	
		DebugTime.print("Main window will hide.")
		
		clearContents()
		saveContents()
		
		notificationHandlers.releaseAll()
		
		super.viewWillDisappear()
	}
	
	override func viewDidDisappear() {

		DebugTime.print("Main window did hide.")
		
		super.viewDidDisappear()		
	}
	
	override func restoreState(with coder: NSCoder) {
		
		super.restoreState(with: coder)
		NSLog("🌴 restoreStateWithCoder Passed.")
	}

	func verifyCredentials() {

		guard NSApp.isReadyForUse else {
		
			return
		}
		
		twitterController.verifyCredentialsIfNeed()
//		twitterController.verifyCredentialsIfNeed { result in
//
//			switch result {
//
//			case .success:
//				NSLog("Twitter credentials verified successfully.")
//
//			case .failure(let error):
//				self.showErrorAlert(withTitle: "Failed to verify credentials", message: error.localizedDescription)
//			}
//		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	var canOpenBrowserWithSearchHashtagPage:Bool {
	
		return !hashTagTextField.hashtags.isEmpty
	}
	
	func openBrowserWithSearchHashtagPage() {
		
		guard canOpenBrowserWithSearchHashtagPage else {
			
			fatalError("Cannot open browser.")
		}
		
		do {

			try ESTwitter.Browser.openWithQuery(query: hashTagTextField.hashtags.twitterQueryText)
		}
		catch let ESTwitter.Browser.BrowseError.OperationFailure(reason: reason) {
			
			self.showErrorAlert(withTitle: "Failed to open browser", message: reason)
		}
		catch {

			self.showErrorAlert(withTitle: "Failed to open browser", message: "Unknown error : \(error)")
		}
	}

	var canOpenBrowserWithCurrentTwitterStatus:Bool {
		
		return self.selectedStatuses.count == 1
	}
	
	func openBrowserWithCurrentTwitterStatus() {
		
		guard self.canOpenBrowserWithCurrentTwitterStatus else {
			
			fatalError("Cannot open browser.")
		}
		
		let status = self.selectedStatuses.first!
		
		do {
			
			try ESTwitter.Browser.openWithStatus(status: status)
		}
		catch let ESTwitter.Browser.BrowseError.OperationFailure(reason: reason) {
			
			self.showErrorAlert(withTitle: "Failed to open browser", message: reason)
		}
		catch {
			
			self.showErrorAlert(withTitle: "Failed to open browser", message: "Unknown error : \(error)")
		}
	}
}

extension MainViewController : NSTextFieldDelegate, NSTextViewDelegate {
	
	func controlTextDidChange(_ notification: Notification) {
		
		self.withChangeValue(for: "canPost")
		self.updateControlsDisplayText()
	}
	
	func control(_ control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
		
		switch control {
			
		case is HashtagTextField:
			return []
			
		default:
			return []
		}
	}
	
	func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
		
		return []
	}
}

extension MainViewController : ViewControllerSelectionAndRepliable {

	func clearReplyTo() {
	
		withChangeValue(for: "canPost") {
			
			statusForReplyTo = nil
			updateControlsDisplayText()
		}
	}
	
	func setReplyToBySelectedStatuses() {
		
		guard canReplyToSelectedStatuses else {
			
			return
		}
		
		withChangeValue(for: "canPost") {
		
			statusForReplyTo = selectedStatuses.first!
			updateControlsDisplayText()
		}
	}
}

extension MainViewController : LatestTweetReplyable {
	
	func resetLatestTweet() {
		
		self.latestTweet = nil
	}
	
	func setReplyToByLatestTweet() {
		
		withChangeValue(for: "canPost") {
			
			statusForReplyTo = latestTweet
			
			updateControlsDisplayText()
		}
	}
}
