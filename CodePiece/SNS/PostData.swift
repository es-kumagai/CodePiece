//
//  PostData.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

private let jsonDecoder = JSONDecoder()

enum PostResult {
	
	case success(PostDataContainer)
	case failure(PostDataContainer)
}

struct PostData {
	
	var code: String?
	var description: String
	var language: ESGists.Language
	var hashtags: ESTwitter.HashtagSet
	var usePublicGists: Bool
	var replyTo: ESTwitter.Status?
	
	var appendAppTagToTwitter:Bool = false
}

enum PostDataError : Error {
	
	case TwitterRawObjectsParseError(rawObjects: [String : Any])
}

final class PostDataContainer {

	var data: PostData
	
	private(set) var stage = PostStage.Initialized
	private(set) var gistsState = GistsState()
	private(set) var twitterState = TwitterState()
	private(set) var error: SNSController.PostError? = nil
	
	init(_ data: PostData) {
		
		self.data = data
	}

	struct TwitterState {
		
		var postedStatus: ESTwitter.Status? = nil
		var mediaIDs: [String] = []
	}
	
	struct GistsState {
	
		var gist: ESGists.Gist? = nil
	}

	enum PostStage {
		
		case Initialized
		case PostToGists
		case CaptureGists
		case PostToTwitter
		case PostToTwitterMedia
		case PostToTwitterStatus
		case Posted
	}
}

extension PostDataContainer {
	
	func postedToTwitter(postedStatus status: Status) {
		
		self.twitterState.postedStatus = status
	}
	
	func postedToGist(gist: ESGists.Gist) {
		
		self.gistsState.gist = gist
	}
	
	func proceedToNextStage() {
		
		switch self.stage {
			
		case .Initialized:
			self.stage = (self.hasCode ? .PostToGists : .PostToTwitter)
			
		case .PostToGists:
			self.stage = .CaptureGists
			
		case .CaptureGists:
			self.stage = .PostToTwitter
			
		case .PostToTwitter:
			self.stage = (self.hasGist ? .PostToTwitterMedia : .PostToTwitterStatus)
			
		case .PostToTwitterMedia:
			self.stage = .PostToTwitterStatus
			
		case .PostToTwitterStatus:
			self.stage = .Posted
			
		case .Posted:
			break
		}
	}
	
	var posted: Bool {
	
		if case .Posted = self.stage {
			
			return true
		}
		else {
			
			return false
		}
	}
	
	var hasError: Bool {
	
		return self.error != nil
	}
	
	var hasCode: Bool {
		
		return self.data.code != nil
	}
	
	var hasMediaIDs: Bool {
		
		return !self.twitterState.mediaIDs.isEmpty
	}
	
	func setError(error: SNSController.PostError) {
	
		self.error = error
	}
	
	func resetError() {
		
		self.error = nil
	}
	
	var twitterReplyToStatusID: String? {
	
		return self.data.replyTo?.idStr
	}
	
	func setTwitterMediaIDs(mediaIDs: [String]) {
		
		self.twitterState.mediaIDs = mediaIDs
	}
	
	func setTwitterMediaIDs(_ mediaIDs: String...) {
	
		self.setTwitterMediaIDs(mediaIDs: mediaIDs)
	}
	
	func effectiveHashtags(withAppTag:Bool, withLangTag:Bool) -> ESTwitter.HashtagSet {
		
		let apptag: ESTwitter.Hashtag? = withAppTag ? CodePieceApp.hashtag : nil
		let langtag: ESTwitter.Hashtag? = withLangTag ? self.data.language.hashtag : nil
		
		return [ apptag, langtag ].reduce(data.hashtags) { tags, tag in
			
			if let tag = tag {
				
				return ESTwitter.HashtagSet(tags + [ tag ])
			}
			else {
				
				return tags
			}
		}
	}
	
	func makeDescriptionWithEffectiveHashtags(hashtags:ESTwitter.HashtagSet, maxLength:Int? = nil, appendString:String? = nil) -> String {
		
		func getTruncatedDescription(_ description: String, maxLength: Int) -> String {
			
			let descriptionLength = maxLength - hashtags.twitterDisplayTextLength
			
			guard description.count > descriptionLength else {
				
				return description
			}
			
			let sourceDescription = description
			
			let start = sourceDescription.startIndex
			let end = sourceDescription.index(start, offsetBy: descriptionLength - 2)
			
			return String(sourceDescription.prefix(through: end)) + " …"
		}
		
		func getDescription() -> String {

			if let maxLength = maxLength {
				
				return getTruncatedDescription(data.description, maxLength: maxLength)
			}
			else {
				
				return data.description
			}
		}
		
		return getDescription()
			.appendStringIfNotEmpty(string: appendString, separator: " ")
			.appendStringIfNotEmpty(string: hashtags.toTwitterDisplayText(), separator: " ")
	}
}
