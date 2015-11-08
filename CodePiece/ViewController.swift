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

class ViewController: NSViewController {

	private var postingHUD:ProgressHUD = ProgressHUD(message: "Posting...", useActivityIndicator: true)
	
	typealias PostResult = SNSController.PostResult
	
	@IBOutlet var postButton:NSButton!
	@IBOutlet var hashTagTextField:HashtagTextField!
	
	@IBOutlet var languagePopUpButton:NSPopUpButton!

	@IBOutlet var languagePopUpDataSource:LanguagePopupDataSource!
	
	@IBOutlet var codeTextView:NSTextView! {
	
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
	
	@IBOutlet weak var descriptionTextField:NSTextField!
	@IBOutlet weak var descriptionCountLabel:NSTextField!
	
	@IBOutlet weak var codeScrollView:NSScrollView!
	
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
			!self.descriptionTextField.stringValue.isEmpty
		]
		
		return meetsAllOf(conditions, true)
	}
	
	var hasCode:Bool {
	
		return !self.codeTextView.string!.trimmed().isEmpty
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
		
		do {

			try self.post { result in
				
				defer {
					
					self.posting = false
					self.postingHUD.hide()
				}
				
				switch result {
					
				case .Success(let info):
					PostCompletelyNotification(info: info).post()
					
				case .Failure(let info):
					PostFailedNotification(info: info).post()
				}
			}
		}
		catch SNSControllerError.NotAuthorized {
			
			// from Gists
			self.posting = false
			self.postingHUD.hide()
			
			self.showErrorAlert("Cannot post", message: "The authentication token is not correct. Please re-authentication.")
		}
		catch {
			
			self.posting = false
			self.postingHUD.hide()
			
			self.showErrorAlert("Cannot post", message: String(error))
		}
	}
	
	func post(callback:(PostResult)->Void) throws {
		
		DebugTime.print("📮 Try to post ... #1")
		
		let code = self.codeTextView.string!
		let language = self.selectedLanguage
		let description = self.descriptionTextField.stringValue
		let hashtag = self.hashTagTextField.hashtag

		if self.hasCode {
			
			DebugTime.print("📮 Try posting with a Code ... #1.1")

			try NSApp.snsController.post(code, language: language, description: description, hashtag: hashtag) { result in
				
				DebugTime.print("📮 Posted \(result) ... #1.1.1")
				
				switch result {
					
				case .Success:
					callback(PostResult(value: SNSController.PostResultInfo()))
					
				case .Failure(let errorInfo):
					callback(PostResult(error: errorInfo))
				}
			}
		}
		else {
			
			DebugTime.print("📮 Try posting without Codes ... #1.2")
			
			try NSApp.twitterController.post(description, hashtag: hashtag) { result in
				
				DebugTime.print("📮 Posted \(result) ... #1.2.1")
				
				switch result {
					
				case .Success:
					callback(PostResult(value: SNSController.PostResultInfo()))
					
				case .Failure(let error):
					callback(PostResult(error: SNSController.PostErrorInfo(error, SNSController.PostResultInfo())))
				}
			}
		}
	}
	
	func clearContents() {
		
		self.clearCodeText()
		self.clearDescriptionText()

		self.updateControlsDisplayText()
	}
	
	func clearCodeText() {
		
		self.codeTextView.string = ""
	}
	
	func clearDescriptionText() {
		
		self.descriptionTextField.stringValue = ""
	}
	
	func clearHashtag() {
		
		self.hashTagTextField.hashtag = ""
	}
	
	func restoreContents() {

		DebugTime.print("Restoring contents in main window.")
		
		NSApp.settings.appState.selectedLanguage.invokeIfExists(self.languagePopUpDataSource.selectLanguage)
		NSApp.settings.appState.hashtag.invokeIfExists { self.hashTagTextField.hashtag = $0 }
	}
	
	func saveContents() {
		
		DebugTime.print("Saving contents in main window.")
		
		NSApp.settings.appState.selectedLanguage = self.selectedLanguage
		NSApp.settings.appState.hashtag = self.hashTagTextField.hashtag

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
		
		PostCompletelyNotification.observeBy(self) { owner, notification in
			
			self.clearContents()
			NSLog("Posted completely \(notification.info)")
		}
		
		PostFailedNotification.observeBy(self) { owner, notification in
		
			self.showErrorAlert("Cannot post", message: notification.info.error.localizedDescription)
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
		
		NotificationManager.release(owner: self)
		
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

	func focusToDefaultControl() {

		self.focusToCodeArea()
	}
	
	func focusToCodeArea() {
		
		self.codeScrollView.becomeFirstResponder()
	}
	
	func focusToDescription() {
		
		self.descriptionTextField.becomeFirstResponder()
	}
	
	func focusToHashtag() {
		
		self.hashTagTextField.becomeFirstResponder()
	}
	
	func focusToLanguage() {
		
		// MARK: 😒 I don't know how to show NSPopUpButton's submenu manually. The corresponding menu item is disabled too.
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
	
		return !self.hashTagTextField.hashtag.isEmpty
	}
	
	func openBrowserWithSearchHashtagPage() {
		
		guard self.canOpenBrowserWithSearchHashtagPage else {
			
			fatalError("Cannot open browser.")
		}
		
		do {

			try ESTwitter.Browser.openWithQuery(self.hashTagTextField.hashtag.value)
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

	func updateControlsDisplayText() {
		
		self.updateTweetTextCount()
		self.updatePostButtonTitle()
	}
	
	func updateTweetTextCount() {

		let countsForInputText:[Int] = [

			self.descriptionTextField.stringValue.utf16.count,
			self.hashTagTextField.hashtag.length.nonZeroMap { $0 + 1 }
		]
		
		let countsForReserve:[Int] = [

			self.hasCode ? Twitter.SpecialCounting.Media.length + Twitter.SpecialCounting.HTTPSUrl.length + 2 : 0,
			self.hasCode ? self.selectedLanguage.hashtag.length.nonZeroMap { $0 + 1 } : 0
//			self.hasCode ? CodePieceApp.hashtag.length.nonZeroMap { $0 + 1 } : 0
		]

		let counts = countsForInputText + countsForReserve
		let totalCount = counts.reduce(0, combine: +)
		
		self.descriptionCountLabel.stringValue = String(totalCount)
		self.descriptionCountLabel.textColor = SystemColor.NeutralColor.color
	}
	
	func updatePostButtonTitle() {
		
		self.postButton.title = (self.hasCode ? "Post Gist" : "Tweet")
	}
	
	func textDidChange(notification: NSNotification) {
		
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

