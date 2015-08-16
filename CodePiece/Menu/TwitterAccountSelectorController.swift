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

final class TwitterAccountSelectorController : NSObject, AlertDisplayable {
	
	@IBOutlet weak var accountSelector:NSPopUpButton! {
		
		didSet {
			
			self.updateAccountSelector()
		}
	}
	
	lazy var accounts:[ACAccount]! = TwitterController.getAccounts()
	
	var hasAccount:Bool {
		
		return !self.accounts.isEmpty
	}
	
	var headerMenuItem:TwitterAccountMenuItem {
		
		return self.accountSelector.menu!.itemAtIndex(0) as! TwitterAccountMenuItem
	}
	
	func updateAccountSelector() {
		
		self.withChangeValue("hasAccount") {
		
			self.accounts = nil
			
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
	}
	
	func accountSelectorDidChange(sender:TwitterAccountMenuItem!) {

		let headerMenuItem = self.headerMenuItem
		
		guard let account = sender.account where headerMenuItem.differentAccount(account) else {
			
			return
		}
		
		headerMenuItem.account = account
		
		TwitterAccountSelectorDidChangeNotification(account: account).post()
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
