//
//  AboutWindowController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/31.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim

@objcMembers
@MainActor
class AboutWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

		// FIXME: 😨 リサイズさせたくないのですが IB でリサイズを無効化してもできてしまいます。コードでマスクを操作してみましたが、それでも効果がないようでした。メニューからストーリーボードで直接インスタンス化しているのが問題なのかもしれません。
		window!.styleMask.subtract(.resizable)
    }

	static func instantiate() -> AboutWindowController {
		
		let storyboard = NSStoryboard(name: "AboutWindowController", bundle: nil)
		
		return instantiate(storyboard: storyboard)!
	}
	
	static func instantiate(storyboard: NSStoryboard, identifier: String? = nil) -> AboutWindowController? {

		switch identifier {
			
		case let identifier?:
			return storyboard.instantiateController(withIdentifier: identifier) as? AboutWindowController

		case nil:
			return storyboard.instantiateInitialController() as? AboutWindowController
		}
	}

	override var contentViewController: NSViewController? {
	
		get {
			
			super.contentViewController
		}
		
		set {
			
			fatalError("Not supported.")
		}
	}
	
	var aboutViewController: AboutViewController {
	
		super.contentViewController as! AboutViewController
	}
	
	var acknowledgementsName: String? {
		
		didSet {
			
			aboutViewController.acknowledgementsName = acknowledgementsName
		}
	}
	
	var hasAcnowledgements: Bool {
		
		acknowledgementsName != nil
	}
	
	func showWindow() {
		
		showWindow(self)
	}
}

extension AboutWindowController : NSWindowDelegate {
	
	// FIXME: 😨 リサイズさせたくないのですが IB でリサイズを無効化してもできてしまいます。NSWindowDelegate での調整を試みましたが、呼ばれず、効果がないようでした。メニューからストーリーボードで直接インスタンス化しているのが問題なのかもしれません。
	nonisolated func windowShouldZoom(_ window: NSWindow, toFrame newFrame: NSRect) -> Bool {
		
		return false
	}
}
