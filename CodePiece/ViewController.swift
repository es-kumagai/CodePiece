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

class ViewController: NSViewController {

	typealias PostResult = SNSController.PostResult
	
	@IBOutlet weak var hashTagTextField:NSTextField!
	@IBOutlet var codeTextView:NSTextView!
	@IBOutlet weak var descriptionTextField:NSTextField!
	
	@IBOutlet weak var codeScrollView:NSScrollView!
	
	var sns:SNSController!
	
	@IBAction func pushPostButton(sender:NSButton?) {
		
		do {

			try self.post { result in
			
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
			self.showErrorAlert("Cannot post", message: "The authentication token is not correct. Please re-authentication.")
		}
		catch {
			
			self.showErrorAlert("Cannot post", message: String(error))
		}
	}
	
	func post(callback:(PostResult)->Void) throws {
		
		let code = self.codeTextView.string!
		let language = Language.Swift
		let description = self.descriptionTextField.stringValue
		let hashtag = self.hashTagTextField.stringValue

		if self.codeTextView.string!.isEmpty {
			
			try self.sns.twitter.post(description, hashtag: hashtag) { result in
				
				switch result {
					
				case .Success:
					callback(PostResult(value: SNSController.PostResultInfo()))
					
				case .Failure(let error):
					callback(PostResult(error: SNSController.PostErrorInfo(error, SNSController.PostResultInfo())))
				}
			}
		}
		else {
			
			try self.sns.post(code, language: language, description: description, hashtag: hashtag) { result in
				
				switch result {
					
				case .Success:
					callback(PostResult(value: SNSController.PostResultInfo()))
					
				case .Failure(let errorInfo):
					callback(PostResult(error: errorInfo))
				}
			}
		}
	}
	
	func clearContents() {
		
		self.codeTextView.string = ""
		self.descriptionTextField.stringValue = ""
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.codeTextView.font = NSFont(name: "SourceCodePro-Regular", size: 15.0)
		
		self.sns = SNSController()
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		self.focusToDefaultControl()
		self.verifyCredentials()
	}

	func focusToDefaultControl() {
		
		// FIXME: 😟 この方法では NSTextView にフォーカスしてくれません。
		self.codeScrollView.becomeFirstResponder()
	}
	
	func verifyCredentials() {
		
		self.sns.twitter.verifyCredentialsIfNeed { result in
			
			switch result {

			case .Success:
				self.clearContents()
				NSLog("Twitter credentials verified successfully.")
				
			case .Failure(let error):
				self.showErrorAlert("Cannot post", message: String(error))
			}
		}
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	override func viewDidAppear() {
	
		super.viewDidAppear()
		
		
	}
}

