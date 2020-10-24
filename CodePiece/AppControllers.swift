//
//  AppControllers.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/17.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

final class AppGlobalControllers {
	
	private(set) var sns:SNSController!
	private(set) var captureController:WebCaptureController!
	private(set) var reachabilityController:ReachabilityController!
	
	init() {
		
		sns = SNSController()
		captureController = WebCaptureController()
		reachabilityController = try! ReachabilityController()
	}
}
