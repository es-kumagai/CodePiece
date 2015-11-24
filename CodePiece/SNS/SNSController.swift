//
//  SNSController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter
import Result

protocol PostController {

	var canPost:Bool { get }
}

enum SNSControllerError : ErrorType, CustomStringConvertible {

	case CredentialsNotVerified
	case NotAuthorized
	case NotReady(String)
	
	var description:String {
		
		switch self {
			
		case .CredentialsNotVerified:
			return "Credentials not verified."
			
		case .NotAuthorized:
			return "Not authorized."
			
		case .NotReady(let message):
			return message
		}
	}
}

final class SNSController : PostController {

	var gists:GistsController
	var twitter:TwitterController
	
	init() {

		self.gists = GistsController()
		self.twitter = TwitterController()
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
	
	var canPost:Bool {
	
		return gists.canPost && twitter.canPost
	}
	
	func post(content: String, language: ESGists.Language, description: String, hashtags: ESTwitter.HashtagSet, completed: (PostResult) -> Void) throws {
	
		DebugTime.print("📮 Try posting to SNS ... #2")
		
		var resultInfo = PostResultInfo()
		
		let posted = { () -> Void in

			DebugTime.print("📮 Posted successfully (info:\(resultInfo)) ... #2.0.1")
			completed(PostResult(value: resultInfo))
		}
		
		let failedToPost = { (error:NSError) -> Void in
		
			DebugTime.print("📮 Posted with failure (info:\(resultInfo), error:\(error)) ... #2.0.2")
			completed(PostResult(error: PostErrorInfo(error, resultInfo)))
		}
		
		let postByTwitter = { (description:String, gist:ESGists.Gist, image:NSImage?) throws -> Void in
		
			DebugTime.print("📮 Try posting by Twitter ... #2.1")
			
			try self.twitter.post(gist, language: language, description: description, hashtags: hashtags, image: image) { result in

				DebugTime.print("📮 Posted by Twitter (\(result)) ... #2.1.1")
				
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

			DebugTime.print("📮 Try posting by Gists ... #2.2")
			
			try self.gists.post(content, language: language, description: description, hashtags: hashtags) { result in

				DebugTime.print("📮 Posted by Gists ... #2.2.1")
				
				let capture = { (gist:Gist) -> Void in
					
					DebugTime.print("📮 Capturing a gist (\(gist)) ... #2.2.1.1")
					
					let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"

//					let size = NSMakeSize(736.0, 414.0)
					let size = NSMakeSize(560.0, 560.0)

					NSApp.captureController.capture(gist.urls.htmlUrl.rawValue, clientSize: size, userAgent: userAgent) { image in
						
						DebugTime.print("📮 A gist captured ... #2.2.1.1.1")
						
						do {
							
							DebugTime.print("📮 Try posting the capture by twitter ... #2.2.1.1.2")
							
							resultInfo.gist = gist
							try postByTwitter(description, gist, image)
							
							DebugTime.print("📮 The capture posted ... #2.2.1.1.3")
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
				
				switch result {
					
				case .Success(let gist):
					
					capture(gist)
					
				case .Failure(let error):
					
					failedToPost(error)
				}
			}
		}
		
		try postByGists(description)
	}
}
