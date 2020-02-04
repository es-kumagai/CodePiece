//
//  TimelineKindStateController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit

@objc enum TimelineKind : Int, Codable {
	
	case hashtags = 0
	case myTweets = 1
}

final class TimelineKindStateController : NSObject {
	
	var timelineKind: TimelineKind? {
		
		didSet (previousKind) {
			
			guard timelineKind != previousKind else {
				
				return
			}
			
			delegate?.timelineKindStateChanged?(self, kind: timelineKind!)
		}
	}
	
	@IBOutlet weak var delegate: TimelineKindStateDelegate?
	
	@IBOutlet var hashtagsButton: NSButton!
	@IBOutlet var myTweetsButton: NSButton!

	override func awakeFromNib() {
	
		super.awakeFromNib()
		
		updateButtonState()
	}
	
	@IBAction func pushButton(_ button: NSButton) {
	
		defer {
			
			updateButtonState()
		}
		
		switch button {
		
		case hashtagsButton:
			timelineKind = .hashtags
			
		case myTweetsButton:
			timelineKind = .myTweets
			
		default:
			timelineKind = nil
		}
	}
}

private extension TimelineKindStateController {
	
	func updateButtonState() {
		
		func currentState(of kind: TimelineKind?) -> NSButton.StateValue {
		
			switch timelineKind {
				
			case kind:
				return .on
				
			default:
				return .off
			}
		}
		
		hashtagsButton?.state = currentState(of: .hashtags)
		myTweetsButton?.state = currentState(of: .myTweets)
	}
}

extension TimelineKind : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .hashtags:
			return "Hashtags"
			
		case .myTweets:
			return "My Tweets"
		}
	}
}
