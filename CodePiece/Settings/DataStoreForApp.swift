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
		
		private var userDefaults = UserDefaults.standard
		
		init() {
			
		}

		var selectedLanguage:Language? {
			
			get {
				
				return userDefaults.string(forKey: AppState.SelectedLanguageKey).flatMap { Language(rawValue: $0) }
			}
			
			set {
				
				userDefaults.set(newValue?.description, forKey: AppState.SelectedLanguageKey)
			}
		}
		
		var hashtags: ESTwitter.HashtagSet? {
			
			get {
				
				return userDefaults.string(forKey: AppState.HashtagKey).map { ESTwitter.HashtagSet(hashtagsDisplayText: $0) }
			}
			
			set (newHashtags) {
				
				userDefaults.set(newHashtags?.twitterDisplayText, forKey: AppState.HashtagKey)
			}
		}
		
		func save() {
			
			userDefaults.synchronize()
		}
	}
}
