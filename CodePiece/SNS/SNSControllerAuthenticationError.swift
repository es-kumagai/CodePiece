//
//  SNSControllerAuthenticationError.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

extension SNSController {

	enum AuthenticationError : Error {
		
		case credentialsNotVerified
		case notAuthorized(service: Service)
		case notReady(service: Service, description: String)
		case invalidAccount(service: Service, reason: String)
	}
}

extension SNSController.AuthenticationError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .credentialsNotVerified:
			return "Credentials not verified."
			
		case .notAuthorized(let service):
			return "\(service) is not authorized."
			
		case .notReady(let service, let message):
			return "\(service) is not ready. \(message)"
			
		case .invalidAccount(let service, let reason):
			return "Invalid \(service) Account. \(reason)"
		}
	}
}
