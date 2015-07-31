//
//  AboutViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/31.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

public final class AboutViewController: NSViewController {

	public static var acknowledgementsStoryboardName = "AcknowledgementsViewController"
	
	@IBOutlet public weak var appIconImageView:NSImageView?
	@IBOutlet public weak var appNameLabel:NSTextField?
	@IBOutlet public weak var appVersionLabel:NSTextField?
	@IBOutlet public weak var appCopyrightLabel:NSTextField?
	@IBOutlet public weak var showAcknowledgementsButton:NSButton?
	
	@IBAction public func pushShowAcknowledgementsButton(sender:AnyObject?) {
	
		let storyboard = NSStoryboard(name: AboutViewController.acknowledgementsStoryboardName, bundle: self.bundle)
		let viewController = storyboard.instantiateInitialController() as! NSViewController
		
		if var viewController = viewController as? AcknowledgementsIncludedAndCustomizable {
			
			viewController.acknowledgementsName = self.acknowledgementsName!
			viewController.acknowledgementsBundle = self.bundle
		}
		
		self.presentViewControllerAsModalWindow(viewController)
	}
	
	public var name:String? {

		didSet {
			
			self.appNameLabel?.stringValue = self.name ?? "(unknown)"
		}
	}
	
	public var icon:NSImage? {
		
		didSet {
			
			self.appIconImageView?.image = self.icon
		}
	}
	
	public var version:(main: String?, build: String?) {
	
		didSet {

			let main = self.version.main ?? ""
			let build = self.version.build.map { "build \($0)" } ?? ""
			
			let value = main.appendStringIfNotEmpty(build, separator: " ")
			
			self.appVersionLabel?.stringValue = value
		}
	}
	
	public var copyright:String? {
		
		didSet {
			
			self.appCopyrightLabel?.stringValue = self.copyright ?? ""
		}
	}
	
	public var acknowledgementsName:String?
	
	public var hasAcnowledgements:Bool {
		
		return self.acknowledgementsName != nil
	}
	
	public var acknowledgements:Acknowledgements? {
		
		let info = { (name:String) -> (name:String, bundle:NSBundle?) in
			
			(name: name, bundle: self.bundle)
		}

		return self.acknowledgementsName.map(info).flatMap(Acknowledgements.init)
	}
	
	public var bundle:NSBundle?
	
	private var targetBundle:NSBundle {
		
		return self.bundle ?? NSBundle.mainBundle()
	}
	
    override public func viewDidLoad() {
		
        super.viewDidLoad()
		
		let bundle = self.targetBundle

		self.icon = NSApp.applicationIconImage
		self.name = bundle.appName
		self.version = bundle.appVersion
		self.copyright = bundle.appCopyright
    }
	
	public override func viewWillAppear() {
		
		self.showAcknowledgementsButton?.alphaValue = self.hasAcnowledgements ? 1.0 : 0.0
	}
}
