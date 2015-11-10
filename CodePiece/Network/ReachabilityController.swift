//
//  ReachabilityController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/17.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ReachabilitySwift
import ESNotification

extension StatusImageView.Status {

	init(reachabilityState: ReachabilityController.State) {
		
		switch reachabilityState {
			
		case .ViaWiFi:
			self = .Available
			
		case .ViaCellular:
			self = .Available
			
		case .Unreachable:
			self = .Unavailable
		}
	}
}

final class ReachabilityController {

	private let reachability:Reachability!
	
	enum State {
		
		case ViaWiFi
		case ViaCellular
		case Unreachable
		
		init(_ rawState:Reachability.NetworkStatus) {
			
			switch rawState {
				
			case .ReachableViaWiFi:
				self = ViaWiFi
				
			case .ReachableViaWWAN:
				self = ViaCellular
				
			case .NotReachable:
				self = Unreachable
			}
		}
	}
	
	final class ReachabilityChangedNotification : Notification {
		
		private(set) var state:State
		
		init(_ state:State) {
			
			self.state = state
		}
	}

	/// - throws: ReachabilityError
	init() throws {
		
		do {
			
			self.reachability = try Reachability.reachabilityForInternetConnection()
		}
		catch {
			
			self.reachability = nil
			throw error
		}
		
		
		NamedNotification.observe(ReachabilitySwift.ReachabilityChangedNotification, by: self, handler: reachabilityDidChange)
		
		try self.reachability.startNotifier()
	}
	
	var state:State {
		
		return State(self.reachability.currentReachabilityStatus)
	}
	
	func reachabilityDidChange(observer: ReachabilityController, notification:NamedNotification) {
		
		guard notification.object === self.reachability else {
			
			fatalError("Reachability notification posted with unknown reachability object (\(notification.object))")
		}

		ReachabilityChangedNotification(self.state).post()
	}
}

extension ReachabilityController.State : CustomStringConvertible {

	var description:String {
		
		switch self {
			
		case .ViaWiFi:
			return "Wi-Fi"
			
		case .ViaCellular:
			return "Cellular"
			
		case .Unreachable:
			return "Unreachable"
		}
	}
}
