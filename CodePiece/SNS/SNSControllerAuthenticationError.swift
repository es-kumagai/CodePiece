//
//  SNSControllerAuthenticationError.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

extension SNSController {

	enum AuthenticationError : Error {
		
		case CredentialsNotVerified
		case NotAuthorized(service: Service)
		case NotReady(service: Service, description: String)
		case InvalidAccount(service: Service, reason: String)
	}
}

extension SNSController.AuthenticationError : CustomStringConvertible {
	
	var description: String {
		
		switch self {
			
		case .CredentialsNotVerified:
			return "Credentials not verified."
			
		case .NotAuthorized(let service):
			return "\(service) is not authorized."
			
		case .NotReady(let service, let message):
			return "\(service) is not ready. \(message)"
			
		case .InvalidAccount(let service, let reason):
			return "Invalid \(service) Account. \(reason)"
		}
	}
}
