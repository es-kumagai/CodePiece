//
//  HashtagTextField.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/28.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

@objcMembers
final class HashtagTextField : NSTextField {
	
	private var hashtagsBeforeEditing: HashtagSet = []
	
	var hashtags: HashtagSet {

		get {

			return HashtagSet(hashtagsDisplayText: super.stringValue)
		}
		
		set (newHashtags) {
			
			stringValue = newHashtags.sorted().twitterDisplayText
			hashtagsBeforeEditing = newHashtags

			HashtagsDidChangeNotification(hashtags: newHashtags).post()
		}
	}
	
	override var stringValue: String {
		
		set {
			
			super.stringValue = newValue
		}
		
		get {
		
			return hashtags.twitterDisplayText
		}
	}
	
	override func textDidEndEditing(_ notification: Notification) {
		
		// 表示のために代入し直して正規化します。
		stringValue = hashtags.sorted().twitterDisplayText
		
		super.textDidEndEditing(notification)

		// 変更があった場合に限り通知します。
		if hashtags != hashtagsBeforeEditing {

			hashtagsBeforeEditing = hashtags
			
			HashtagsDidChangeNotification(hashtags: hashtags).post()
		}
	}
}
