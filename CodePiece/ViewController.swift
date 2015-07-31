//
//  ViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGist
import Result
import Ocean
import Quartz
import Swim
import ESProgressHUD

class ViewController: NSViewController {

	var postingHUD:ProgressHUD = ProgressHUD(message: "Posting...", useActivityIndicator: true)
	typealias PostResult = SNSController.PostResult
	
	@IBOutlet weak var postButton:NSButton!
	@IBOutlet weak var hashTagTextField:HashtagTextField!

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
	
	@IBAction func pushPostButton(sender:NSObject?) {
	
		self.postToSNS()
	}
	
	func postToSNS() {

		guard self.canPost else {
			
			return
		}

		guard sns.canPost else {
		
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
					self.clearContents()
					NSLog("Posted completely \(info)")
					
				case .Failure(let info):
					self.showErrorAlert("Cannot post", message: info.error.localizedDescription)
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
		
		let code = self.codeTextView.string!
		let language = Language.Swift
		let description = self.descriptionTextField.stringValue
		let hashtag = self.hashTagTextField.hashtag

		if self.hasCode {
			
			try sns.post(code, language: language, description: description, hashtag: hashtag) { result in
				
				switch result {
					
				case .Success:
					callback(PostResult(value: SNSController.PostResultInfo()))
					
				case .Failure(let errorInfo):
					callback(PostResult(error: errorInfo))
				}
			}
		}
		else {
			
			try sns.twitter.post(description, hashtag: hashtag) { result in
				
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
		
		self.codeTextView.string = ""
		self.descriptionTextField.stringValue = ""

		self.updateControlsDisplayText()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		self.focusToDefaultControl()
		self.updateControlsDisplayText()

		self.clearContents()
	}
	
	override func viewDidAppear() {
		
		super.viewDidAppear()
		
		if settings.isReady {
			
			self.verifyCredentials()
		}
		else {
			
			NSApp.showWelcomeBoard()
		}
	}
	
	override func viewDidDisappear() {
		
		super.viewDidDisappear()
		
		NSApp.terminate(self)
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
	
	func verifyCredentials() {

		guard sns != nil else {
		
			return
		}
		
		sns.twitter.verifyCredentialsIfNeed { result in
			
			switch result {

			case .Success:
				NSLog("Twitter credentials verified successfully.")
				
			case .Failure(let error):
				self.showErrorAlert("Failed to verify credentials", message: String(error))
			}
		}
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
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
			CodePieceApp.hashtag.length.nonZeroMap { $0 + 1 }
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
	
	override func controlTextDidChange(obj: NSNotification) {
	
		self.willChangeValueForKey("canPost")
		self.didChangeValueForKey("canPost")
	
		self.updateControlsDisplayText()
	}
}

