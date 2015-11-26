//
//  DataStoreForApp.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/05.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import ESGists
import ESTwitter
import Swim

extension DataStore {

	struct AppState {
		
		static let SelectedLanguageKey = "codepiece:selected-language"
		static let HashtagKey = "codepiece:hashtag"
		
		private var userDefaults:NSUserDefaults
		
		init() {
			
			self.userDefaults = NSUserDefaults.standardUserDefaults()
		}

		var selectedLanguage:Language? {
			
			get {
				
				return self.userDefaults.stringForKey(AppState.SelectedLanguageKey).flatMap { Language(rawValue: $0) }
			}
			
			set {
				
				self.userDefaults.setObject(newValue?.description, forKey: AppState.SelectedLanguageKey)
			}
		}
		
		var hashtags:ESTwitter.HashtagSet? {
			
			get {
				
				return self.userDefaults.stringForKey(AppState.HashtagKey).map { ESTwitter.HashtagSet(hashtagsDisplayText: $0) }
			}
			
			set {
				
				self.userDefaults.setObject(newValue?.toTwitterDisplayText(), forKey: AppState.HashtagKey)
			}
		}
		
		func save() {
			
			self.userDefaults.synchronize()
		}
	}
}