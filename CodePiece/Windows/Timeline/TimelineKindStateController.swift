//
//  TimelineKindStateController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import Ocean

@objc enum TimelineKind : Int, Codable {
	
	case hashtags = 0
	case myTweets = 1
	case mentions = 2
}

enum TimelineState {
	
	case havingNew
	case neutral
}

final class TimelineKindStateController : NSObject, NotificationObservable {

	var notificationHandlers = Notification.Handlers()
	
	
	var timelineKind: TimelineKind? {
		
		didSet (previousKind) {
			
			guard timelineKind != previousKind else {
				
				return
			}
			
			updateButtonState()
			delegate?.timelineKindStateChanged?(self, kind: timelineKind!)
		}
	}
	
	var timelineState: [TimelineKind : TimelineState] = [:]
	
	@IBOutlet weak var delegate: TimelineKindStateDelegate?
	
	@IBOutlet var hashtagsButton: NSButton!
	@IBOutlet var myTweetsButton: NSButton!
	@IBOutlet var mentionsButton: NSButton!

	override func awakeFromNib() {
	
		super.awakeFromNib()
		
		updateButtonState()
		
		observe(notification: MentionUpdatedNotification.self) { [unowned self] notification in
			
			self.timelineState[.mentions] = (notification.hasNewMention ? .havingNew : .neutral)
			self.updateButtonState()
		}
		
		observe(notification: TimelineSelectionChangedNotification.self) { [unowned self] notification in
			
			self.timelineState[notification.timelineViewController.contentsKind] = .neutral
			self.updateButtonState()
		}
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
			
		case mentionsButton:
			timelineKind = .mentions
			
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
		
		func applyState(to button: NSButton?, kind: TimelineKind) {
			
			guard let button = button else {
				
				return
			}
			
			let buttonState = currentState(of: kind)
			let timelineState = self.timelineState[kind] ?? .neutral
			
			var buttonTitleAttributes: [NSAttributedString.Key : Any] {
				
				switch timelineState {
					
				case .havingNew:
					return [.foregroundColor : NSColor.attentionColor]
					
				case .neutral:
					return [:]
				}
			}

			button.state = buttonState
			button.attributedTitle = NSAttributedString(string: button.title, attributes: buttonTitleAttributes)
		}
		
		applyState(to: hashtagsButton, kind: .hashtags)
		applyState(to: myTweetsButton, kind: .myTweets)
		applyState(to: mentionsButton, kind: .mentions)
	}
}

extension TimelineKind : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .hashtags:
			return "Hashtags"
			
		case .myTweets:
			return "My Tweets"
			
		case .mentions:
			return "Mentions"
		}
	}
}
