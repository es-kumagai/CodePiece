////
////  TwitterAccountMenuItem.swift
////  CodePiece
////
////  Created by Tomohiro Kumagai on H27/08/14.
////  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
////
//
//import AppKit
//import Accounts
//
//final class TwitterAccountMenuItem: NSMenuItem {
//
//	private static let IdentifierCoderKey = "TwitterAccountMenuItemIdentifierKey"
//	
//	var account: TwitterController.Account? {
//		
//		didSet {
//			
//			title = TwitterAccountMenuItem.titleOfAccount(account: account)
//		}
//	}
//	
//	static func menuItemCreator(action:Selector, target:AnyObject?) -> (_ account:ACAccount?, _ keyEquivalent:String) -> TwitterAccountMenuItem {
//
//		return { account, keyEquivalent in
//			
//			return TwitterAccountMenuItem(account: account, action: action, target: target, keyEquivalent: keyEquivalent)
//		}
//	}
//	
//	required init(coder aDecoder: NSCoder) {
//
//		if let accountIdentifier = aDecoder.decodeObject(forKey: TwitterAccountMenuItem.IdentifierCoderKey) as? String {
//			
//			NSLog("🐋 Creates Twitter Account Menu Item with identifier.")
//			account = TwitterController.Account(identifier: accountIdentifier)
//		}
//		else {
//			
//			account = nil
//		}
//		
//		super.init(coder: aDecoder)
//	}
//	
//	func differentAccount(account: TwitterController.Account) -> Bool {
//	
//		guard let myAccount = self.account else {
//			
//			return true
//		}
//		
//		return myAccount.identifier != account.identifier
//	}
//	
//	private static func titleOfAccount(account: TwitterController.Account?) -> String {
//		
//		return titleOfAccount(account: account?.acAccount)
//	}
//	
//	private static func titleOfAccount(account: ACAccount?) -> String {
//		
//		return account?.username ?? "----"
//	}
//	
//	override func encode(with aCoder: NSCoder) {
//		
//		super.encode(with: aCoder)
//		
//		aCoder.encode(account?.identifier, forKey: TwitterAccountMenuItem.IdentifierCoderKey)
//	}
//}
