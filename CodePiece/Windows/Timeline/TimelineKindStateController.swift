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

	var tabInformations: Set<TabInformation> = [] {
		
		didSet {
			
			updateButtonState()
		}
	}
	
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

	func prepare() {
	
		tabInformations.insert(.init(kind: .hashtags, button: hashtagsButton, state: .neutral))
		tabInformations.insert(.init(kind: .myTweets, button: myTweetsButton, state: .neutral))
		tabInformations.insert(.init(kind: .mentions, button: mentionsButton, state: .neutral))

		
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
		
		guard let information = tabInformations.first(where: { $0.button === button }) else {
			
			fatalError("INTERNAL ERROR: Unexpected button pushed.\n\(button)")
		}
		
		timelineKind = information.kind
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
		
		for information in tabInformations {
			
			applyState(to: information.button, kind: information.kind)
		}
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
