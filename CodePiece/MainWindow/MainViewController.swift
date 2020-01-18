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
import Quartz
import Swim
import ESProgressHUD
import ESTwitter

@objcMembers
final class MainViewController: NSViewController, NotificationObservable {

	enum ReplyToType {
		
		case None
		case LatestTweet
		case SelectedStatus
	}
	
	var nextReplyToType = ReplyToType.None {
		
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
	
	private var postingHUD:ProgressHUD = ProgressHUD(message: "Posting...", useActivityIndicator: true)
	
	private(set) var latestTweet: ESTwitter.Status?
	private(set) var selectedStatuses = Array<ESTwitter.Status>()
	private(set) var statusForReplyTo: ESTwitter.Status? {
		
		didSet {
			
			if let status = self.statusForReplyTo {
				
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

	@IBOutlet var languagePopUpDataSource: LanguagePopupDataSource! {
		
		didSet {
			
			#warning("実行時に nil になるので動作検証のためのコードです。")
			NSLog("%@", "実行時に nil になるので動作検証のためのコードです。")
		}
	}
	
	@IBOutlet var codeTextView: CodeTextView! {
	
		didSet {
			
			self.codeTextView.font = systemPalette.codeFont

			// MARK: IB からだと自動書式調整のプロパティを変えても効かないので、ここで調整しています。
			self.codeTextView.isAutomaticDashSubstitutionEnabled = false
			self.codeTextView.isAutomaticDataDetectionEnabled = false
			self.codeTextView.isAutomaticLinkDetectionEnabled = false
			self.codeTextView.isAutomaticQuoteSubstitutionEnabled = false
			self.codeTextView.isAutomaticSpellingCorrectionEnabled = false
			self.codeTextView.isAutomaticTextReplacementEnabled = false
			self.codeTextView.isContinuousSpellCheckingEnabled = false
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
	
	var posting:Bool = false {
	
		willSet {
			
			self.willChangeValue(forKey: "canPost")
		}
		
		didSet {
			
			self.didChangeValue(forKey: "canPost")
		}
	}
	
	var canPost:Bool {
	
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
	
	@IBAction func pushPostButton(_ sender:NSObject?) {
	
		self.postToSNS()
	}
	
	func postToSNS() {

		guard self.canPost else {
			
			return
		}

		guard NSApp.snsController.canPost else {
		
			self.showErrorAlert(withTitle: "Not ready", message: "It is not ready to post. Please set SNS accounts by the CodePiece's preferences. (⌘,)")
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
				
			case .Success(let container):
				PostCompletelyNotification(container: container).post()
				
			case .Failure(let container):
				PostFailedNotification(container: container).post()
			}
		}
	}
	
	func post(callback: @escaping (PostResult) -> Void) {
		
		DebugTime.print("📮 Try to post ... #1")
		
		NSApp.snsController.post(container: makePostDataContainer()) { container in
			
			DebugTime.print("📮 Posted \(container.twitterState.postedStatus) ... #1.1.1")
			
			if container.posted {
				
				callback(PostResult.Success(container))
			}
			else {
				
				callback(PostResult.Failure(container))
			}
		}
	}
	
	func restoreContents() {

		DebugTime.print("Restoring contents in main window.")
		
		NSApp.settings.appState.selectedLanguage.executeIfExists(expression: self.languagePopUpDataSource.selectLanguage)
		NSApp.settings.appState.hashtags.executeIfExists { self.hashTagTextField.hashtags = $0 }
	}
	
	func saveContents() {
		
		DebugTime.print("Saving contents in main window.")
		
		NSApp.settings.appState.selectedLanguage = self.selectedLanguage
		NSApp.settings.appState.hashtags = self.hashTagTextField.hashtags

		NSApp.settings.saveAppState()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		DebugTime.print("Main window loaded.")
	}
	
	override func viewWillAppear() {
		
		DebugTime.print("Main window will show.")

		super.viewWillAppear()

		self.restoreContents()
		self.focusToDefaultControl()
		self.updateControlsDisplayText()

		self.clearContents()
		
		self.observe(notification: PostCompletelyNotification.self) { [unowned self] notification in
			
			self.clearContents()
			self.latestTweet = notification.container.twitterState.postedStatus
			self.nextReplyToType = .LatestTweet
			
			NSLog("Posted completely \(notification.container.twitterState.postedStatus)")
		}
		
		observe(notification: PostFailedNotification.self) { [unowned self] notification in
			
			self.showErrorAlert(withTitle: "Cannot post", message: notification.container.error!.description)
		}
		
		observe(notification: LanguagePopupDataSource.LanguageSelectionChanged.self) { [unowned self] notification in
			
			self.updateWatermark()
			self.updateTweetTextCount()
		}
		
		observe(notification: TimelineViewController.TimelineSelectionChangedNotification.self) { [unowned self] notification in
			
			guard notification.selectedCells.count == 1 else {

				self.selectedStatuses = []
				return
			}

			self.selectedStatuses = notification.selectedCells.compactMap { $0.cell?.item?.status }
			self.nextReplyToType = .SelectedStatus
			
			print("Selection Changed : \(self.selectedStatuses.map { "\($0.user.screenName) : \($0.text)" } )")
		}
		
		observe(notification: TimelineViewController.TimelineReplyToSelectionRequestNotification.self) { [unowned self] notification in
			
			self.setReplyTo(notification)
		}
	}
	
	override func viewDidAppear() {
		
		DebugTime.print("Main window did show.")
		
		super.viewDidAppear()
		
		if !NSApp.settings.isReady && NSApp.environment.showWelcomeBoardOnStartup {
			
			NSApp.showWelcomeBoard()
		}
	}
	
	override func viewWillDisappear() {
	
		DebugTime.print("Main window will hide.")
		
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
		
		twitterController.verifyCredentialsIfNeed { result in
			
			switch result {

			case .success:
				NSLog("Twitter credentials verified successfully.")
				
			case .failure(let error):
				self.showErrorAlert(withTitle: "Failed to verify credentials", message: error.localizedDescription)
			}
		}
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

			try ESTwitter.Browser.openWithQuery(query: self.hashTagTextField.hashtags.toTwitterDisplayText())
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
	
	func textDidChange(_ notification: Notification) {
		
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
			
			self.statusForReplyTo = nil
			updateControlsDisplayText()
		}
	}
	
	func setReplyToBySelectedStatuses() {
		
		guard canReplyToSelectedStatuses else {
			
			return
		}
		
		withChangeValue(for: "canPost") {
		
			self.statusForReplyTo = selectedStatuses.first!
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
			
			self.statusForReplyTo = latestTweet
			
			updateControlsDisplayText()
		}
	}
}
