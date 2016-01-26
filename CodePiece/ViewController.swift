//
//  ViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGists
import Result
import Ocean
import Quartz
import Swim
import ESProgressHUD
import ESTwitter
import ESNotification

class ViewController: NSViewController, NotificationObservable {

	var notificationHandlers = NotificationHandlers()
	
	private var postingHUD:ProgressHUD = ProgressHUD(message: "Posting...", useActivityIndicator: true)

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
	
	@IBOutlet var postButton:NSButton!
	@IBOutlet var hashTagTextField:HashtagTextField!
	
	@IBOutlet var languagePopUpButton:NSPopUpButton!

	@IBOutlet var languagePopUpDataSource:LanguagePopupDataSource!
	
	@IBOutlet var codeTextView:CodeTextView! {
	
		didSet {
			
			guard let font = SystemFont.FontForCode.fontWithSize(15.0) else {
				
				NSLog("Failed to get a font for the CodeTextView.")
				return
			}
			
			self.codeTextView.font = font

			// MARK: IB からだと自動書式調整のプロパティを変えても効かないので、ここで調整しています。
			self.codeTextView.automaticDashSubstitutionEnabled = false
			self.codeTextView.automaticDataDetectionEnabled = false
			self.codeTextView.automaticLinkDetectionEnabled = false
			self.codeTextView.automaticQuoteSubstitutionEnabled = false
			self.codeTextView.automaticSpellingCorrectionEnabled = false
			self.codeTextView.automaticTextReplacementEnabled = false
			self.codeTextView.continuousSpellCheckingEnabled = false
		}
	}
	
	@IBOutlet var descriptionTextField:DescriptionTextField!
	@IBOutlet var descriptionCountLabel:NSTextField!
	
	@IBOutlet var codeScrollView:NSScrollView!
	
	var baseViewController:BaseViewController {
		
		return self.parentViewController as! BaseViewController
	}
	
	var posting:Bool = false {
	
		willSet {
			
			self.willChangeValueForKey("canPost")
		}
		
		didSet {
			
			self.didChangeValueForKey("canPost")
		}
	}
	
	var canPost:Bool {
	
		let conditions = [
			
			!self.posting,
			!self.descriptionTextField.twitterText.isEmpty,
			self.codeTextView.hasCode || !self.descriptionTextField.isReplyAddressOnly
		]
		
		return meetsAllOf(conditions, true)
	}
	
	var selectedLanguage:Language {
		
		return self.languagePopUpButton.selectedItem.flatMap { Language(displayText: $0.title) }!
	}
	
	@IBAction func pushPostButton(sender:NSObject?) {
	
		self.postToSNS()
	}
	
	func postToSNS() {

		guard self.canPost else {
			
			return
		}

		guard NSApp.snsController.canPost else {
		
			self.showErrorAlert("Not ready", message: "It is not ready to post. Please set SNS accounts by the CodePiece's preferences. (⌘,)")
			return
		}
		
		self.posting = true
		self.postingHUD.show()
		
		self.post { result in
			
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
	
	func post(callback:(PostResult)->Void) {
		
		DebugTime.print("📮 Try to post ... #1")
		
		let postDataContainer = self.makePostDataContainer()
		
		NSApp.snsController.post(postDataContainer) { container in
			
			DebugTime.print("📮 Posted \(container.twitterState.postedObjects) ... #1.1.1")
			
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
		
		NSApp.settings.appState.selectedLanguage.invokeIfExists(self.languagePopUpDataSource.selectLanguage)
		NSApp.settings.appState.hashtags.invokeIfExists { self.hashTagTextField.hashtags = $0 }
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
		
		self.observeNotification(PostCompletelyNotification.self) { [unowned self] notification in
			
			self.clearContents()
			NSLog("Posted completely \(notification.container.twitterState.postedObjects)")
		}
		
		self.observeNotification(PostFailedNotification.self) { [unowned self] notification in
		
			self.showErrorAlert("Cannot post", message: "\(notification.container.error!)")
		}
		
		self.observeNotification(LanguagePopupDataSource.LanguageSelectionChanged.self) { [unowned self] notification in
			
			self.updateTweetTextCount()
		}
		
		observeNotification(TimelineViewController.TimelineSelectionChangedNotification.self) { [unowned self] notification in
			
			guard notification.selectedCells.count == 1 else {

				self.selectedStatuses = []
				return
			}

			self.selectedStatuses = notification.selectedCells.flatMap { $0.cell?.item?.status }
			
			print("Selection Changed : \(self.selectedStatuses.map { "\($0.user.screenName) : \($0.text)" } )")
		}
		
		observeNotification(TimelineViewController.TimelineReplyToSelectionRequestNotification.self) { [unowned self] notification in
			
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
		
		self.saveContents()
		self.releaseAllObservingNotifications()
		
		super.viewWillDisappear()
	}
	
	override func viewDidDisappear() {

		DebugTime.print("Main window did hide.")
		
		super.viewDidDisappear()		
	}
	
	override func restoreStateWithCoder(coder: NSCoder) {
		
		super.restoreStateWithCoder(coder)
		NSLog("🌴 restoreStateWithCoder Passed.")
	}

	func verifyCredentials() {

		guard NSApp.isReadyForUse else {
		
			return
		}
		
		NSApp.twitterController.verifyCredentialsIfNeed { result in
			
			switch result {

			case .Success:
				NSLog("Twitter credentials verified successfully.")
				
			case .Failure(let error):
				self.showErrorAlert("Failed to verify credentials", message: error.localizedDescription)
			}
		}
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}
	
	var canOpenBrowserWithSearchHashtagPage:Bool {
	
		return !self.hashTagTextField.hashtags.isEmpty
	}
	
	func openBrowserWithSearchHashtagPage() {
		
		guard self.canOpenBrowserWithSearchHashtagPage else {
			
			fatalError("Cannot open browser.")
		}
		
		do {

			try ESTwitter.Browser.openWithQuery(self.hashTagTextField.hashtags.toTwitterDisplayText())
		}
		catch let ESTwitter.Browser.Error.OperationFailure(reason: reason) {
			
			self.showErrorAlert("Failed to open browser", message: reason)
		}
		catch {

			self.showErrorAlert("Failed to open browser", message: "Unknown error : \(error)")
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
			
			try ESTwitter.Browser.openWithStatus(status)
		}
		catch let ESTwitter.Browser.Error.OperationFailure(reason: reason) {
			
			self.showErrorAlert("Failed to open browser", message: reason)
		}
		catch {
			
			self.showErrorAlert("Failed to open browser", message: "Unknown error : \(error)")
		}
	}
}

extension ViewController : NSTextFieldDelegate, NSTextViewDelegate {
	
	func textDidChange(notification: NSNotification) {
		
		self.withChangeValue("canPost")
		self.updateControlsDisplayText()
	}
	
	override func controlTextDidChange(notification: NSNotification) {
	
		self.withChangeValue("canPost")
		self.updateControlsDisplayText()
	}
	
	func control(control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
		
		switch control {
			
		case is HashtagTextField:
			return []
			
		default:
			return []
		}
	}
	
	func textView(textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
		
		return []
	}
}

extension ViewController : ViewControllerSelectionAndRepliable {

	func clearReplyTo() {
	
		withChangeValue("canPost") {
			
			self.statusForReplyTo = nil
			updateControlsDisplayText()
		}
	}
	
	func setReplyToBySelectedStatuses() {
		
		guard canReplyToSelectedStatuses else {
			
			return
		}
		
		withChangeValue("canPost") {
			
			self.statusForReplyTo = selectedStatuses.first!
			updateControlsDisplayText()
		}
	}
}
