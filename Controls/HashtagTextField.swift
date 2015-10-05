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
	
	private var hashtagBeforeEditing = ESTwitter.Hashtag()
	
	var hashtag:ESTwitter.Hashtag {

		get {

			return ESTwitter.Hashtag(super.stringValue)
		}
		
		set {
			
			self.stringValue = newValue.value
			self.hashtagBeforeEditing = newValue

			HashtagDidChangeNotification(hashtag: newValue).post()
		}
	}
	
	override var stringValue:String {
		
		set {
			
			super.stringValue = newValue
		}
		
		get {
		
			return self.hashtag.value
		}
	}
	
	override func textDidEndEditing(notification: NSNotification) {
		
		// 表示のために代入し直して正規化します。
		self.stringValue = self.hashtag.value
		
		super.textDidEndEditing(notification)

		// 変更があった場合に限り通知します。
		if self.hashtag != self.hashtagBeforeEditing {

			self.hashtagBeforeEditing = self.hashtag
			
			HashtagDidChangeNotification(hashtag: self.hashtag).post()
		}
	}
}
