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

@objcMembers
@MainActor
final class LanguagePopupDataSource : NSObject {
	
	let defaultLanguage = Language.swift
	
	@IBOutlet var popupButton: NSPopUpButton! {
		
		didSet {

			popupButton.addItem(withTitle: defaultLanguage.description)
			
			for language in languages.sorted() {

				let menu = applyingExpression(to: NSMenuItem(title: language.description, action: #selector(LanguagePopupDataSource.popupSelected(_:)), keyEquivalent: "")) {
					
					$0.target = self
				}
				
				popupButton.menu!.addItem(menu)
			}
		}
	}
	
	private(set) var languages: Set<Language>!
	
	@MainActor
	override func awakeFromNib() {
		
		super.awakeFromNib()

		let popularLanguages = PopularLanguage.allCases.map(Language.init)
		let popularLanguageSet = LanguageSet(popularLanguages)
		let others: LanguageSet = [ .text, .kotlin ]
		
		languages = popularLanguageSet.union(others)
	}
	
	func selectLanguage(_ language: Language) {
	
		popupButton.selectItem(withTitle: language.description)
		popupButton.selectedItem.executeIfExists { popupSelected($0) }
	}
	
	func popupSelected(_ item: NSMenuItem) {
		
		popupButton.title = item.title
		Language(displayText: item.title).map(LanguageSelectionChanged.init)!.post()
	}
}

extension LanguagePopupDataSource {
	
	struct LanguageSelectionChanged : NotificationProtocol {
		
		let language: Language
	}
}
