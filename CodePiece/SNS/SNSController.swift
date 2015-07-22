//
//  SNSController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGist
import Result

protocol PostController {

}

enum SNSControllerError : ErrorType, CustomStringConvertible {

	case CredentialsNotVerified
	case NotAuthorized
	
	var description:String {
		
		switch self {
			
		case .CredentialsNotVerified:
			return "Credentials not verified."
			
		case .NotAuthorized:
			return "Not authorized."
		}
	}
}

final class SNSController : PostController {

	var gists:GistsController
	var twitter:TwitterController
	
	init() {

		self.gists = GistsController()
		self.twitter = TwitterController(account: .First)!
	}
	
	struct PostResultInfo {
	
		var gist:Gist?
		var status:String?
	}
	
	enum PostErrorInfo : ErrorType {
		
		case Info(NSError,PostResultInfo)
		
		init(_ error:NSError, _ info:PostResultInfo) {
			
			self = .Info(error, info)
		}
		
		var error:NSError {
			
			switch self {
				
			case let .Info(error, _):
				return error
//				
//			default:
//				fatalError()
			}
		}
	}
	
	typealias PostResult = Result<PostResultInfo,PostErrorInfo>
	
	func post(content: String, language: ESGist.Language, description: String, hashtag: String, completed: (PostResult) -> Void) throws {
	
		var resultInfo = PostResultInfo()
		
		let posted = { () -> Void in

			completed(PostResult(value: resultInfo))
		}
		
		let failedToPost = { (error:NSError) -> Void in
		
			completed(PostResult(error: PostErrorInfo(error, resultInfo)))
		}
		
		let postByTwitter = { (description:String, gist:ESGist.Gist) throws -> Void in
		
			try self.twitter.post(gist, language: language, description: description, hashtag: hashtag) { result in

				switch result {
					
				case .Success(let status):
					
					resultInfo.status = status
					posted()
					
				case .Failure(let error):
					
					failedToPost(error)
				}
			}
		}
		
		let postByGists = { (description:String) throws -> Void in

			try self.gists.post(content, language: language, description: description, hashtag: hashtag) { result in

				do {

					switch result {
						
					case .Success(let gist):

						resultInfo.gist = gist
						try postByTwitter(description, gist)
						
					case .Failure(let error):

						failedToPost(error)
					}					
				}
				catch SNSControllerError.NotAuthorized {
					
					failedToPost(NSError(domain: SNSControllerError.NotAuthorized.description, code: -1, userInfo: nil))
				}
				catch SNSControllerError.CredentialsNotVerified {
					
					failedToPost(NSError(domain: SNSControllerError.CredentialsNotVerified.description, code: -1, userInfo: nil))
				}
				catch let error as NSError {
					
					failedToPost(error)
				}
				catch {

					failedToPost(NSError(domain: String(error), code: -1, userInfo: nil))
				}
			}
		}
		
		try postByGists(description)
	}
}
