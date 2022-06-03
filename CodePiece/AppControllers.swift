//
//  AppControllers.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/17.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

@MainActor
final class AppGlobalControllers : NSObject {
	
	private(set) var sns: SNSController!
	private(set) var captureController: WebCaptureController!
	private(set) var reachabilityController: ReachabilityController!
	
	@MainActor
	override init() {
		
		super.init()
		
		let captureController = WebCaptureController()
		
		self.sns = SNSController(captureController: captureController)
		self.captureController = captureController
		self.reachabilityController = try! ReachabilityController()
	}
}
