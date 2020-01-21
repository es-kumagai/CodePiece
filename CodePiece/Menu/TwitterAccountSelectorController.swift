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

@available(macOS, deprecated: 10.15, message: "This class no longer needed.")
@objcMembers
final class TwitterAccountSelectorController : NSObject, AlertDisplayable {
	
//	@IBOutlet var accountSelector:NSPopUpButton! {
//
//		didSet {
//
//			self.updateAccountSelector()
//		}
//	}
//
//	lazy var accounts:[ACAccount]! = TwitterController.getAccounts()
//
//	var hasAccount:Bool {
//
//		return !self.accounts.isEmpty
//	}
//
//	var headerMenuItem:TwitterAccountMenuItem {
//
//		return self.accountSelector.menu!.item(at: 0) as! TwitterAccountMenuItem
//	}
	
//	func updateAccountSelector() {
//
//		self.withChangeValue(for: "hasAccount") {
//
//			self.accounts = nil
//
//			let createMenuItem = TwitterAccountMenuItem.menuItemCreator(action: #selector(TwitterAccountSelectorController.accountSelectorDidChange(_:)), target: self)
//
//			applyingExpression(to: accountSelector) {
//
//				let currentAccount = NSApp.settings.account.twitterAccount?.acAccount
//
//				$0.removeAllItems()
//				$0.menu!.addItem(createMenuItem(account: currentAccount, keyEquivalent: ""))
//
//				for account in self.accounts {
//
//					$0.menu!.addItem(createMenuItem(account: account, keyEquivalent: ""))
//				}
//			}
//		}
//	}
	
//	func accountSelectorDidChange(_ sender:TwitterAccountMenuItem!) {
//
//		let headerMenuItem = self.headerMenuItem
//
//		guard let account = sender.account, headerMenuItem.differentAccount(account: account) else {
//
//			return
//		}
//
//		headerMenuItem.account = account
//
//		TwitterAccountSelectorDidChangeNotification(account: account).post()
//	}
//
//	func accountByIdentifier(identifier: String!) -> ACAccount? {
//
//		return self.accounts.first {
//
//			$0.identifier.isEqual(to: identifier)
//		}
//	}
//
//	func accountByName(name:String!) -> ACAccount? {
//
//		return self.accounts.first {
//
//			$0.username == name
//		}
//	}
	
}
