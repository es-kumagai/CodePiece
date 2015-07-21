//
//  ViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/19.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGist

class ViewController: NSViewController {

	@IBOutlet weak var hashTagTextField:NSTextField!
	@IBOutlet var codeTextView:NSTextView!
	@IBOutlet weak var descriptionTextField:NSTextField!
	
	@IBOutlet weak var codeScrollView:NSScrollView!
	
	@IBAction func pushPostButton(sender:NSButton?) {
		
		let content = self.codeTextView.string!
		let language = Language.Swift
		let description = self.descriptionTextField.stringValue
		let hashtag = self.hashTagTextField.stringValue
		
		GistsController.post(content, language: language, description: description, hashtag: hashtag) { gist in
			
			self.clear()
			NSLog("Posted to \(gist?.urls.htmlUrl)")
		}
	}
	
	func clear() {
		
		self.codeTextView.string = ""
		self.descriptionTextField.stringValue = ""
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.codeTextView.font = NSFont(name: "SourceCodePro-Regular", size: 15.0)
	}
	
	override func viewWillAppear() {
		
		super.viewWillAppear()
		
		self.codeScrollView.becomeFirstResponder()
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

