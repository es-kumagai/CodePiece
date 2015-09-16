//
//  LanguagePopupDataSource.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESGists
import Swim
import ESNotification

final class LanguagePopupDataSource : NSObject {
	
	let defaultLanguage = Language.Swift
	
	@IBOutlet weak var popupButton:NSPopUpButton! {
		
		didSet {

			self.popupButton.addItemWithTitle(self.defaultLanguage.description)
			
			for language in self.languages {

				let menu = tweak (NSMenuItem(title: language.description, action: "popupSelected:", keyEquivalent: "")) {
					
					$0.target = self
				}
				
				self.popupButton.menu!.addItem(menu)
			}
		}
	}
	
	let languages = PopularLanguage.all.languages.sort()
	
	override func awakeFromNib() {
	
		super.awakeFromNib()
	}
	
	func selectLanguage(language:Language) {
	
		self.popupButton.selectItemWithTitle(language.description)
		self.popupButton.selectedItem.invokeIfExists(self.popupSelected)
	}
	
	func popupSelected(item:NSMenuItem) {
		
		self.popupButton.title = item.title
		
		Language(displayText: item.title).map(LanguageSelectionChanged.init)!.post()
	}
}

extension LanguagePopupDataSource {
	
	final class LanguageSelectionChanged : Notification {
		
		var language:Language
		
		init(language: Language) {
			
			self.language = language
		}
	}
}
