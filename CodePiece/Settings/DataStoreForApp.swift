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

	@MainActor
	struct AppState {
		
		enum Key : String, Sendable {
			
			case selectedLanguage = "codepiece:selected-language"
			case hashtag = "codepiece:hashtag"
			case description = "codepiece:description"
			case code = "codepiece:code"
		}
		
		private var userDefaults = UserDefaults.standard
		
		init() {
			
		}

		var selectedLanguage: Language? {
			
			get {
				
				userDefaults.string(forKey: Key.selectedLanguage.rawValue).flatMap { Language(rawValue: $0) }
			}
			
			set {
				
				userDefaults.set(newValue?.description, forKey: Key.selectedLanguage.rawValue)
			}
		}
		
		var hashtags: HashtagSet? {
			
			get {
				
				userDefaults.string(forKey: Key.hashtag.rawValue).map { ESTwitter.HashtagSet(hashtagsDisplayText: $0) }
			}
			
			set (newHashtags) {
				
				userDefaults.set(newHashtags?.twitterDisplayText, forKey: Key.hashtag.rawValue)
			}
		}

		var description: String? {
			
			get {
				
				userDefaults.string(forKey: Key.description.rawValue)
			}
			
			set (newCode) {
				
				userDefaults.set(newCode, forKey: Key.description.rawValue)
			}
		}
		
		var code: String? {
			
			get {
				
				userDefaults.string(forKey: Key.code.rawValue)
			}
			
			set (newCode) {
				
				userDefaults.set(newCode, forKey: Key.code.rawValue)
			}
		}
		
		func save() {
			
			userDefaults.synchronize()
		}
	}
}
