//
//  HashtagTextField.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/28.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESTwitter

final class HashtagTextField : NSTextField {
	
	private var hashtagsBeforeEditing:ESTwitter.HashtagSet = []
	
	var hashtags:ESTwitter.HashtagSet {

		get {

			return ESTwitter.HashtagSet(hashtagsDisplayText: super.stringValue)
		}
		
		set {
			
			self.stringValue = newValue.toTwitterDisplayText()
			self.hashtagsBeforeEditing = newValue

			HashtagsDidChangeNotification(hashtags: newValue).post()
		}
	}
	
	override var stringValue:String {
		
		set {
			
			super.stringValue = newValue
		}
		
		get {
		
			return self.hashtags.toTwitterDisplayText()
		}
	}
	
	override func textDidEndEditing(notification: NSNotification) {
		
		// 表示のために代入し直して正規化します。
		self.stringValue = self.hashtags.toTwitterDisplayText()
		
		super.textDidEndEditing(notification)

		// 変更があった場合に限り通知します。
		if self.hashtags != self.hashtagsBeforeEditing {

			self.hashtagsBeforeEditing = self.hashtags
			
			HashtagsDidChangeNotification(hashtags: self.hashtags).post()
		}
	}
}
