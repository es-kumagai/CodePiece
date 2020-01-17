//
//  LanguagePopupDataSource.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGists
import Ocean
import Swim

final class LanguagePopupDataSource : NSObject {
	
	let defaultLanguage = Language.swift
	
	@IBOutlet var popupButton:NSPopUpButton! {
		
		didSet {

			self.popupButton.addItem(withTitle: self.defaultLanguage.description)
			
			for language in languages.sort() {

				let menu = applyingExpression(to: NSMenuItem(title: language.description, action: #selector(LanguagePopupDataSource.popupSelected(_:)), keyEquivalent: "")) {
					
					$0.target = self
				}
				
				self.popupButton.menu!.addItem(menu)
			}
		}
	}
	
	let languages: Set<Language> = { () -> Set<Language> in
		
		let populars = Set(PopularLanguage.allCases.map(Language.init))
		let others = [ .text, .kotlin ] as Set<Language>
		
		return populars.union(others)
	}()
	
	override func awakeFromNib() {
	
		super.awakeFromNib()
	}
	
	func selectLanguage(_ language:Language) {
	
		self.popupButton.selectItem(withTitle: language.description)
		self.popupButton.selectedItem.executeIfExists(expression: self.popupSelected)
	}
	
	@objc func popupSelected(_ item: NSMenuItem) {
		
		self.popupButton.title = item.title
		
		Language(displayText: item.title).map(LanguageSelectionChanged.init)!.post()
	}
}

extension LanguagePopupDataSource {
	
	final class LanguageSelectionChanged : NotificationProtocol {
		
		var language:Language
		
		init(language: Language) {
			
			self.language = language
		}
	}
}
