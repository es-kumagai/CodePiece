//
//  PostData.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

enum PostResult {
	
	case Success(PostDataContainer)
	case Failure(PostDataContainer)
}

struct PostData {
	
	var code: String?
	var description: String
	var language: ESGists.Language
	var hashtags: ESTwitter.HashtagSet
	var usePublicGists: Bool
	
	var appendAppTagToTwitter:Bool = false
}

final class PostDataContainer {

	var data: PostData
	
	private(set) var stage = PostStage.Initialized
	private(set) var gistsState = GistsState()
	private(set) var twitterState = TwitterState()
	private(set) var error: PostError? = nil
	
	init(_ data: PostData) {
		
		self.data = data
	}

	struct TwitterState {
		
		var postedObjects: [NSObject:AnyObject]? = nil
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

struct PostError : ErrorType {
	
	var reason: String
	
	init(reason: String) {
		
		self.reason = reason
	}
	
	init<T:ErrorType>(error: T) {
		
		self.reason = "\(error)"
	}
}

extension PostDataContainer {
	
	func postedToTwitter(postedObjects: [NSObject:AnyObject]) {
		
		self.twitterState.postedObjects = postedObjects
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
	
		return self.error.isExists
	}
	
	var hasCode: Bool {
		
		return self.data.code.isExists
	}
	
	var hasMediaIDs: Bool {
		
		return !self.twitterState.mediaIDs.isEmpty
	}
	
	func setError(error: PostError) {
	
		self.error = error
	}
	
	func resetError() {
		
		self.error = nil
	}
	
	func setTwitterMediaIDs(mediaIDs: [String]) {
		
		self.twitterState.mediaIDs = mediaIDs
	}
	
	func setTwitterMediaIDs(mediaIDs: String...) {
	
		self.setTwitterMediaIDs(mediaIDs)
	}
	
	func effectiveHashtags(withAppTag withAppTag:Bool, withLangTag:Bool) -> ESTwitter.HashtagSet {
		
		let apptag = withAppTag ? CodePieceApp.hashtag : ESTwitter.Hashtag()
		let langtag = withLangTag ? self.data.language.hashtag : ESTwitter.Hashtag()
		
		return ESTwitter.HashtagSet(self.data.hashtags + [ apptag, langtag ])
	}
	
	func makeDescriptionWithEffectiveHashtags(hashtags:ESTwitter.HashtagSet, withAppTag:Bool, withLangTag:Bool, maxLength:Int? = nil, appendString:String? = nil) -> String {
		
		let getTruncatedDescription = { (description: String, maxLength: Int) -> String in
			
			let descriptionLength = maxLength - hashtags.twitterDisplayTextLength
			
			guard description.characters.count > descriptionLength else {
				
				return description
			}
			
			let sourceDescription = description.characters
			
			let start = sourceDescription.startIndex
			let end = start.advancedBy(descriptionLength - 2)
			
			return String(sourceDescription.prefixThrough(end)) + " …"
		}
		
		let getDescription = { () -> String in

			let description = self.data.description
			
			if let maxLength = maxLength {
				
				return getTruncatedDescription(description, maxLength)
			}
			else {
				
				return description
			}
		}
		
		return getDescription()
			.appendStringIfNotEmpty(appendString, separator: " ")
			.appendStringIfNotEmpty(hashtags.toTwitterDisplayText(), separator: " ")
	}
}
