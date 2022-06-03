//
//  ReachabilityController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/17.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import Reachability
import Ocean

extension StatusImageView.Status {

	init(reachabilityState: ReachabilityController.State) {
		
		switch reachabilityState {
			
		case .viaWiFi:
			self = .available
			
		case .viaCellular:
			self = .available
			
		case .unreachable:
			self = .unavailable
		}
	}
}

final class ReachabilityController : NotificationObservable {
	
	let notificationHandlers = Notification.Handlers()
	
	private let reachability: Reachability!
	
	/// - throws: ReachabilityError
	init() throws {
		
		do {
			
			reachability = try Reachability()
		}
		catch {
			
			reachability = nil
			throw error
		}
		
		observe(notificationNamed: .reachabilityChanged) { [unowned self] notification in
			
			ReachabilityChangedNotification(state: state).post()
		}
		
		try reachability.startNotifier()
	}
	
	deinit {
		
		notificationHandlers.releaseAll()
	}
	
	var state: State {
		
		State(reachability.connection)
	}
}

extension ReachabilityController {
	
	enum State : Sendable {
		
		case viaWiFi
		case viaCellular
		case unreachable
		
		init(_ rawState: Reachability.Connection) {
			
			switch rawState {
				
			case .wifi:
				self = .viaWiFi
				
			case .cellular:
				self = .viaCellular
				
			case .unavailable, .none:
				self = .unreachable
			}
		}
	}
	
	struct ReachabilityChangedNotification : NotificationProtocol, Sendable {
		
		let state: State
	}
}

extension ReachabilityController.State : CustomStringConvertible {

	var description:String {
		
		switch self {
			
		case .viaWiFi:
			return "Wi-Fi"
			
		case .viaCellular:
			return "Cellular"
			
		case .unreachable:
			return "Unreachable"
		}
	}
}
