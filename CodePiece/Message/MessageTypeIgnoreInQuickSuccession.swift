//
//  MessageTypeIgnoreInQuickSuccession.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/23
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import Swim

public protocol MessageTypeIgnoreInQuickSuccession : PreActionMessageType {
	
	/// Returns true if the message may block in quick succession.
	var mayBlockInQuickSuccession: Bool { get }
	
	func blockInQuickSuccession(lastMessage: Self) -> Bool
}

extension MessageTypeIgnoreInQuickSuccession {
	
	public var mayBlockInQuickSuccession: Bool {
		
		return true
	}
	
	public func messagePreAction(queue: Queue<Self>) -> Continuous {
		
		guard mayBlockInQuickSuccession else {
		
			return .continue
		}
		
		if let lastMessage = queue.back, blockInQuickSuccession(lastMessage: lastMessage) {
			
			return .abort
		}
		else {
			
			return .continue
		}
	}
}

extension MessageTypeIgnoreInQuickSuccession where Self : Equatable {
	
	public func blockInQuickSuccession(lastMessage: Self) -> Bool {
		
		self == lastMessage
	}
}
