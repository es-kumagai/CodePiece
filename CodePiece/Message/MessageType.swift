//
//  MessageQueueMessageType.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/23
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

public protocol MessageType : Sendable {
	
	/// Call when the message send completely.
	func messageQueued()
	
	/// Call when the message blocked.
	func messageBlocked()
}

extension MessageType {
	
	/// Call when the message send completely.
	public func messageQueued() {
		
	}
	
	/// Call when the message blocked.
	public func messageBlocked() {
		
	}
}
