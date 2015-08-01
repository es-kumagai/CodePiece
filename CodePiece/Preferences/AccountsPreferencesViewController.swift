//
//  AccountsPreferencesViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class AccountsPreferenceViewController: NSSplitViewController {

	override func awakeFromNib() {
		
		super.awakeFromNib()

		let size = CGSize(width: 480.0, height: 270.0)
		self.view.frame = self.view.frame.replaced(size: size)
	}
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		let githubPreferencesViewController = Storyboard.GitHubPreferenceView.defaultViewController as! GitHubPreferenceViewController
		let twitterPreferencesViewController = Storyboard.TwitterPreferenceView.defaultViewController as! TwitterPreferenceViewController
		
		let githubItem = NSSplitViewItem(viewController: githubPreferencesViewController)
		let twitterItem = NSSplitViewItem(viewController: twitterPreferencesViewController)
		
		self.addSplitViewItem(githubItem)
		self.addSplitViewItem(twitterItem)
    }
}
