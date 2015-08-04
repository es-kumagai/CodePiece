//
//  HashtagTextField.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/28.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

final class HashtagTextField : NSTextField {
	
	var hashtag:Twitter.Hashtag {

		get {

			return Twitter.Hashtag(super.stringValue)
		}
		
		set {
			
			self.stringValue = newValue.value
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
		
		// 代入し直して正規化します。
		self.stringValue = self.hashtag.value
	}
}
