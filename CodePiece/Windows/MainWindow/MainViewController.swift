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
import CodePieceCore

@objcMembers
final class MainViewController: NSViewController, NotificationObservable {

	let maxDescriptionLength = 140
	
	enum ReplyToType {
		
		case none
		case latestTweet
		case selectedStatus
	}
	
//	var nextReplyToType = ReplyToType.none {
//
//		willSet {
//
//			willChangeValue(forKey: "canReplyTo")
//		}
//
//		didSet {
//
//			didChangeValue(forKey: "canReplyTo")
//		}
//	}
	
	var notificationHandlers = Notification.Handlers()
	
	var twitterController: TwitterController {
		
		return NSApp.snsController.twitter
	}
	
	private var postingHUD: ProgressHUD = ProgressHUD(message: "Posting...", useActivityIndicator: true)
	
	private var activeSearchTweetsWindowController: SearchTweetsWindowController? = nil
	
	private(set) var latestTweet: ESTwitter.Status?
	
//	private(set) var selectedStatuses = Array<ESTwitter.Status>()
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
	
		DebugTime.print("Text Count: \(descriptionTextField.integerValue)")
		let conditions = [
			
			!posting,
			!descriptionTextField.twitterText.isEmpty,
			descriptionCountForPost <= maxDescriptionLength,
			codeTextView.hasCode || !descriptionTextField.isReplyAddressOnly
		]
		
		return conditions.meetsAll(of: true)
	}
	
	var descriptionCountForPost: Int {
		
		let includesGistsLink = codeTextView.hasCode
		let totalCount = makePostDataContainer().descriptionLengthForTwitter(includesGistsLink: includesGistsLink)
		
		return totalCount
	}
	
	var selectedLanguage: Language {
		
		return languagePopUpButton.selectedItem.flatMap { Language(displayText: $0.title) }!
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
	
		saveContents()
		postToSNS()
	}
	
	func postToSNS() {

		guard canPost else {
			
			return
		}

		guard NSApp.snsController.canPost else {
		
			showErrorAlert(withTitle: "Not ready to post", message: "Please set SNS accounts on the app's preferences. If you'd like to open the preference, type `⌘,`.)")
			return
		}
		
		posting = true
		postingHUD.show()
		
		post { [unowned self] result in
			
			defer {
				
				posting = false
				postingHUD.hide()
			}
			
			switch result {
				
			case .success(let container):
				PostCompletelyNotification(container: container, postedStatus: container.twitterState.postedStatus, hashtags: hashTagTextField.hashtags).post()
				
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
		
		observe(PostCompletelyNotification.self) { [unowned self] notification in
			
			let container = notification.container
			
			clearContents()
			latestTweet = container.twitterState.postedStatus

			saveContents()

			if let error = container.latestError {
				
				showErrorAlert(withTitle: "Finish posting, but ...", message: "\(error)")
			}
			
			NSLog("Posted completely \(notification.container.twitterState.postedStatus?.text ?? "(unknown)")")
		}
		
		observe(PostFailedNotification.self) { [unowned self] notification in
			
			showErrorAlert(withTitle: "Failed to post", message: "\(notification.error)")
		}
		
		observe(HashtagsChangeRequestNotification.self) { [unowned self] notification in
			
			hashTagTextField.hashtags = notification.hashtags
		}
		
		observe(LanguageSelectionChangeRequestNotification.self) { [unowned self] notification in
			
			languagePopUpDataSource.selectLanguage(notification.language)
		}
		
		observe(CodeChangeRequestNotification.self) { [unowned self] notification in
			
			codeTextView.string = notification.code
		}
		
		observe(LanguagePopupDataSource.LanguageSelectionChanged.self) { [unowned self] notification in
			
			updateWatermark()
			updateTweetTextCount()
			saveContents()
		}
		
		observe(HashtagsDidChangeNotification.self) { [unowned self] notification in

			saveContents()
		}
		
		observe(TimelineSelectionChangedNotification.self) { notification in
			
			let selectedStatuses = notification.selectedCells.compactMap { $0.cell?.item?.status }
			
			print("Selection Changed : \(selectedStatuses.map { "\($0.user.screenName) : \($0.text.prefix(20))" } )")
		}
		
		observe(TimelineReplyToSelectionRequestNotification.self) { [unowned self] notification in
			
			setReplyTo(notification)
			view.window?.makeKeyAndOrderFront(self)
		}
		
		observe(TwitterController.AuthorizationStateInvalidNotification.self) { [unowned self] notification in
			
			if NSApp.settings.isReady {
			
				DebugTime.print("Authorization State is invalid. Try authenticating.")
				twitterController.authorize()
			}
		}
		
		observe(TwitterController.AuthorizationStateDidChangeNotification.self) { [unowned self] notification in
			
			withChangeValue(for: "CanPost")
		}

		observe(TwitterController.AuthorizationStateDidChangeWithErrorNotification.self) { [unowned self] notification in

			switch notification.error {

			case .notAuthorized(let message):

				showErrorAlert(withTitle: "Failed to authorization", message: message)

			default:
				showErrorAlert(withTitle: "Failed to authorization", message: "\(notification.error)")
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
		activeSearchTweetsWindowController?.close()
		
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
	
	var canOpenBrowserWithSearchHashtagPage: Bool {
	
		return !hashTagTextField.hashtags.isEmpty
	}
	
	var canOpenBrowserWithRelatedTweets: Bool {
	
		return canOpenBrowserWithSearchHashtagPage
	}
	
	func openBrowserWithSearchHashtagPage() {
		
		guard canOpenBrowserWithSearchHashtagPage else {
			
			let message = "UNEXPECTED ERROR: Try to open related tweets with browser, but don't ready to open it. (hashtags: \(hashTagTextField.hashtags))"
			
			NSLog("%@", message)
			assertionFailure(message)
			
			return
		}
		
		do {

			try ESTwitter.Browser.openWithQuery(hashTagTextField.hashtags.searchQuery)
		}
		catch let ESTwitter.Browser.BrowseError.OperationFailure(reason: reason) {
			
			showErrorAlert(withTitle: "Failed to open browser", message: reason)
		}
		catch {

			showErrorAlert(withTitle: "Failed to open browser", message: "Unknown error : \(error)")
		}
	}

	func openSearchTweetsWindow() {
		
		guard activeSearchTweetsWindowController == nil else {
			
			activeSearchTweetsWindowController?.window?.makeKeyAndOrderFront(self)
			return
		}
		
		let controller = try! Storyboard.searchTweetsWindow.instantiateController()

		controller.showWindow(self)
		controller.delegate = self

		activeSearchTweetsWindowController = controller
	}
	
	func openBrowserWithRelatedTweets() {
		
		guard canOpenBrowserWithRelatedTweets else {
			
			let message = "UNEXPECTED ERROR: Try to open related tweets with browser, but don't ready to open it. (hashtags: \(hashTagTextField.hashtags))"
			
			NSLog("%@", message)
//			assertionFailure(message)
			
			return
		}
		
		do {

			guard let timelineContents = NSApp.timelineTabViewController.timelineContentsController(of: .relatedTweets) as? RelatedTweetsContentsController else {
				
				fatalError("INTERNAL ERROR: Failed to get the Related Tweets Contents Controller.")
			}
			
			try ESTwitter.Browser.openWithQuery(timelineContents.relatedUsers.queryForSearchingAllUsersTweets())
		}
		catch let ESTwitter.Browser.BrowseError.OperationFailure(reason: reason) {
			
			showErrorAlert(withTitle: "Failed to open browser", message: reason)
		}
		catch {

			showErrorAlert(withTitle: "Failed to open browser", message: "Unknown error : \(error)")
		}
	}
}

extension MainViewController : NSTextFieldDelegate, NSTextViewDelegate {
	
	func controlTextDidChange(_ notification: Notification) {
		
		withChangeValue(for: "canPost")
		updateControlsDisplayText()
	}
	
	/// Invoke this method when CodeTextView (NSTextView) did change.
	func textDidChange(_ notification: Notification) {

		withChangeValue(for: "canPost")
		updateControlsDisplayText()
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

extension MainViewController {

	func clearReplyingStatus() {
	
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
		
			statusForReplyTo = NSApp.currentSelectedStatuses.first!
			updateControlsDisplayText()
		}
	}
}

extension MainViewController {
	
	func resetLatestTweet() {
		
		latestTweet = nil
	}
	
	var hasLatestTweet: Bool {
		
		return latestTweet != nil
	}

	func setReplyToByLatestTweet() {
		
		withChangeValue(for: "canPost") {
			
			statusForReplyTo = latestTweet
			
			updateControlsDisplayText()
		}
	}
}

extension MainViewController : SearchTweetsWindowControllerDelegate {

	func searchTweetsWindowControllerWillClose(_ sender: SearchTweetsWindowController) {

		activeSearchTweetsWindowController = nil
	}
}
