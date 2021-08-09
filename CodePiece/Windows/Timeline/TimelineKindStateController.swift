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
	case relatedTweets = 3
	
	case searchTweets = -1
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
	@IBOutlet var relatedTweetsButton: NSButton!

	func prepare() {
	
		// Register Timeline View Controllers
		
		tabInformations.register(HashtagsContentsController.self, for: .hashtags, button: hashtagsButton)
		tabInformations.register(MyTweetsContentsController.self, for: .myTweets, button: myTweetsButton, autoUpdateInterval: 60)
		tabInformations.register(MentionsContentsController.self, for: .mentions, button: mentionsButton)
		tabInformations.register(RelatedTweetsContentsController.self, for: .relatedTweets, button: relatedTweetsButton)
		
		
		observe(MentionUpdatedNotification.self) { [unowned self] notification in
			
			timelineState[.mentions] = (notification.hasNewMention ? .havingNew : .neutral)
			updateButtonState()
		}
		
		observe(TimelineSelectionChangedNotification.self) { [unowned self] notification in
			
			timelineState[notification.timelineViewController.contentsKind] = .neutral
			updateButtonState()
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
			
		case .relatedTweets:
			return "Related Tweets"
			
		case .searchTweets:
			return "Search Tweets"
		}
	}
}

private extension Set where Element == TimelineKindStateController.TabInformation {
	
	static var nextTabOrder = 0
	
	mutating func register<T: TimelineContentsController>(_ controller: T.Type, for kind: TimelineKind, button: NSButton, state: TimelineState = .neutral, autoUpdateInterval interval: Double? = nil) {

		insert(Element(kind: kind, button: button, state: state, controller: T.init(), autoUpdateInterval: interval, tabOrder: Self.nextTabOrder))
		
		Self.nextTabOrder += 1
	}
}
