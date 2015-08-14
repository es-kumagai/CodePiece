//
//  TwitterAccountSelectorController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/14.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Accounts
import Swim

final class TwitterAccountSelectorController : NSObject {
	
	@IBOutlet weak var accountSelector:NSPopUpButton! {
		
		didSet {
			
			self.updateAccountSelector()
		}
	}
	
	lazy var accounts:[ACAccount]! = sns.twitter.getAccounts()
	
	func updateAccountSelector() {
		
		let createMenuItem = TwitterAccountMenuItem.menuItemCreator(action: "accountSelectorDidChange:", target: self)
		
		tweak (self.accountSelector) {
			
			let currentAccount = settings.account.twitterAccount?.ACAccount
			
			$0.removeAllItems()
			$0.menu!.addItem(createMenuItem(account: currentAccount, keyEquivalent: ""))
			
			for account in self.accounts {
				
				$0.menu!.addItem(createMenuItem(account: account, keyEquivalent: ""))
			}
		}
	}
	
	func accountSelectorDidChange(sender:TwitterAccountMenuItem!) {

		let account = sender.account
		
		tweak (self.accountSelector.menu!.itemAtIndex(0) as! TwitterAccountMenuItem) {
			
			$0.account = account
		}
		
		settings.account.twitterAccount = TwitterAccount.Specified(account!.identifier!)
		sns.twitter.account = TwitterAccount.Specified(account!.identifier!)
	}
	
	func accountByIdentifier(identifier:String!) -> ACAccount? {
		
		let found = self.accounts.findElement {
			
			$0.identifier == identifier
		}
		
		return found?.element
	}
	
	func accountByName(name:String!) -> ACAccount? {
		
		let found = self.accounts.findElement {
			
			$0.username == name
		}
		
		return found?.element
	}
	
}
