//
//  AboutViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/31.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
final class AboutViewController: NSViewController {

	public static var acknowledgementsStoryboardName = "AcknowledgementsViewController"
	
	@IBOutlet public weak var appIconImageView:NSImageView?
	@IBOutlet public weak var appNameLabel:NSTextField?
	@IBOutlet public weak var appVersionLabel:NSTextField?
	@IBOutlet public weak var appCopyrightLabel:NSTextField?
	@IBOutlet public weak var showAcknowledgementsButton:NSButton?
	
	@IBAction public func pushShowAcknowledgementsButton(_ sender:AnyObject?) {
	
		let storyboard = NSStoryboard(name: AboutViewController.acknowledgementsStoryboardName, bundle: bundle)
		let viewController = storyboard.instantiateInitialController() as! NSViewController
		
		if var viewController = viewController as? AcknowledgementsIncludedAndCustomizable {
			
			viewController.acknowledgementsName = acknowledgementsName!
			viewController.acknowledgementsBundle = bundle
		}
		
		presentAsModalWindow(viewController)
	}
	
	public override var title:String? {
	
		get {

			return super.title ?? ""
		}
		
		set {
			
			super.title = newValue
		}
	}
	
	public var name:String? {

		didSet {
			
			appNameLabel?.stringValue = name ?? "(unknown)"
		}
	}
	
	public var icon:NSImage? {
		
		didSet {
			
			appIconImageView?.image = icon
		}
	}
	
	public var version:String? {
	
		didSet {
			
			appVersionLabel?.stringValue = version ?? ""
		}
	}
	
	public var copyright:String? {
		
		didSet {
			
			appCopyrightLabel?.stringValue = copyright ?? ""
		}
	}
	
	public var acknowledgementsName:String?
	
	public var hasAcnowledgements:Bool {
		
		return acknowledgementsName != nil
	}
	
	public var acknowledgements:Acknowledgements? {
		
		let info = { (name:String) -> (name:String, bundle:Bundle?) in
			
			(name: name, bundle: self.bundle)
		}

		return acknowledgementsName.map(info).flatMap(Acknowledgements.init)
	}
	
	public var bundle:Bundle?
	
	private var targetBundle:Bundle {
		
		return bundle ?? Bundle.main
	}
	
    override public func viewDidLoad() {
		
        super.viewDidLoad()
		
		let bundle = targetBundle

		icon = NSApp.applicationIconImage
		name = bundle.appName
		version = bundle.appVersionString
		copyright = bundle.appCopyright
    }
	
	public override func viewWillAppear() {
		
		showAcknowledgementsButton?.alphaValue = hasAcnowledgements ? 1.0 : 0.0
	}
}
