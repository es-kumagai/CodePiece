//
//  APIKit.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/23
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import APIKit
import Foundation

extension APIKit.Session {
	
	/// Calls `send(_:callbackQueue:handler:)` of `Session.shared`.
	/// - parameter request: The request to be sent.
	/// - parameter callbackQueue: The queue where the handler runs. If this parameters is `nil`, default `callbackQueue` of `Session` will be used.
	/// - parameter handler: The closure that receives result of the request.
	/// - returns: The new session task.
	@discardableResult
	public class func send<Request: APIKit.Request>(_ request: Request) async throws -> Request.Response {

		try await withCheckedThrowingContinuation { continuation in
			
			send(request, handler: continuation.resume)
		}
	}
}

extension APIKit.SessionTaskError : CustomStringConvertible {
	
	public var description: String {
		
		switch self {
			
		case .connectionError(let error):
			return "\(error)"
			
		case .requestError(let error):
			 return "\(error)"
			
		case .responseError(let error):
			return "\(error)"
		}
	}
}

extension APIKit.SessionTaskError : CustomNSError {
	
	public var errorUserInfo: [String : Any] {
		
		[NSLocalizedDescriptionKey : description]
	}
}
