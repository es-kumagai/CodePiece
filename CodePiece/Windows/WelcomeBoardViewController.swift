//
//  WelcomeBoardViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Ocean

class WelcomeBoardViewController: NSViewController {

	@IBOutlet weak var iconView:NSImageView!
	@IBOutlet weak var appNameLabel:NSTextField!
	@IBOutlet weak var appVersionLabel:NSTextField!

	@IBAction func pushQuitAppButton(sender:AnyObject!) {

		NSApp.terminate(self)
	}
	
	@IBAction func pushStartConfigurationButton(sender:AnyObject!) {

		// 視覚的に WelcomeBoard を閉じてから showPreferencesWindow を開きたいところですが dispatch で実行を遅らせると、モーダルな設定画面からの認証で応答が得られなくなるため、表示が残ったまま設定画面をモーダル表示しています。
		NSApp.closeWelcomeBoard()
		NSApp.showPreferencesWindow()
	}
	
	override func viewDidLoad() {

		super.viewDidLoad()
		
		let bundle = NSBundle.mainBundle()
		
		self.iconView.image = NSApp.applicationIconImage
		self.appNameLabel.stringValue = bundle.appName!
		self.appVersionLabel.stringValue = bundle.appVersionString
    }
}
