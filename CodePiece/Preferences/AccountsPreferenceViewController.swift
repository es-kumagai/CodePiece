//
//  AccountsPreferencesViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/01.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

class AccountsPreferenceViewController: NSSplitViewController {

	private var totalWidth:CGFloat = 480.0
	private var totalHeight:CGFloat = 270.0
	
	override func awakeFromNib() {
		
		super.awakeFromNib()

		self.view.frame = self.view.frame.replaced(size: CGSize(width: self.totalWidth, height: self.totalHeight))
	}
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		let githubPreferencesViewController = Storyboard.GitHubPreferenceView.defaultViewController as! GitHubPreferenceViewController
		let twitterPreferencesViewController = Storyboard.TwitterPreferenceView.defaultViewController as! TwitterPreferenceViewController

		let totalHeight:CGFloat = self.totalHeight
		let eachHeight = totalHeight.halfValue.truncate() - 20.0
		
		let applyConstraints = { (view:NSView) -> Void in

			let isBaseView = (view === self.view)
			let height:CGFloat = (isBaseView ? self.totalHeight : eachHeight)
			
			let widthConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: self.totalWidth)
			let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: height)

			view.addConstraint(widthConstraint)
			view.addConstraint(heightConstraint)
		}
		
		applyConstraints(self.view)
		applyConstraints(githubPreferencesViewController.view)
		applyConstraints(twitterPreferencesViewController.view)
		
		let githubItem = NSSplitViewItem(viewController: githubPreferencesViewController)
		let twitterItem = NSSplitViewItem(viewController: twitterPreferencesViewController)
		
		self.addSplitViewItem(githubItem)
		self.addSplitViewItem(twitterItem)
    }
}
