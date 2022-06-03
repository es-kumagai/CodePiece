//
//  PostData.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter
import CodePieceCore

private let jsonDecoder = JSONDecoder()

//enum PostDataError : Error {
//	
//	case TwitterRawObjectsParseError(rawObjects: [String : Any])
//}

actor PostDataContainer {

	var data: PostData
	
	private(set) var stage = PostStage.initialized
	private(set) var gistsState = GistsState()
	private(set) var twitterState = TwitterState()
	
	@available(*, message: "Concurrency に対応したら、エラーを状態としてもたなくても throwing で済むかもしれません。")
	private(set) var errors: [SNSController.PostError] = []
	
	init(_ data: PostData) {
		
		self.data = data
	}
}

extension PostDataContainer {

	struct TwitterState {
		
		var postedStatus: ESTwitter.Status? = nil
		var mediaIDs: [String] = []
	}
	
	struct GistsState {
	
		var gist: ESGists.Gist? = nil
	}

	enum PostStage : CaseIterable {
		
		case initialized
		case postToGists
		case captureGists
		case postProcessToTwitter
		case postToTwitterMedia
		case postToTwitterStatus
		case posted
	}
}

extension PostDataContainer {
	
	func postedToTwitter(postedStatus status: Status) {
		
		twitterState.postedStatus = status
	}
	
	func postedToGist(gist: ESGists.Gist) {
		
		gistsState.gist = gist
	}
	
	func proceedToNextStage() {
		
		switch stage {
			
		case .initialized:
			stage = (hasCode ? .postToGists : .postProcessToTwitter)
			
		case .postToGists:
			stage = .captureGists
			
		case .captureGists:
			stage = .postProcessToTwitter
			
		case .postProcessToTwitter:
			stage = (hasGist ? .postToTwitterMedia : .postToTwitterStatus)
			
		case .postToTwitterMedia:
			stage = .postToTwitterStatus
			
		case .postToTwitterStatus:
			stage = .posted
			
		case .posted:
			break
		}
	}
	
	var posted: Bool {
	
		if case .posted = stage {
			
			return true
		}
		else {
			
			return false
		}
	}
	
	var hasError: Bool {
	
		return errors.count > 0
	}
	
	var hasCode: Bool {
		
		return !data.code.isEmpty
	}
	
	var hasMediaIDs: Bool {
		
		return !twitterState.mediaIDs.isEmpty
	}
	
	var latestError: SNSController.PostError? {
		
		return errors.last
	}
	
	func setError(_ error: SNSController.PostError) {
	
		errors.append(error)
	}
	
	func clearErrors() {
		
		errors.removeAll()
	}
	
	var twitterReplyToStatusID: String? {
	
		return data.replyTo?.idStr
	}
	
	func setTwitterMediaIDs(mediaIDs: [String]) {
		
		twitterState.mediaIDs = mediaIDs
	}
	
	func setTwitterMediaIDs(_ mediaIDs: String...) {
	
		setTwitterMediaIDs(mediaIDs: mediaIDs)
	}
	
	func effectiveHashtags(withAppTag: Bool, withLangTag: Bool) -> [Hashtag] {
		
		var hashtags = data.hashtags

		if withLangTag {
		
			let langTag = data.language.hashtag
			
			hashtags.removeAll { $0 == langTag }
			hashtags.append(langTag)
		}
		
		if withAppTag {
			
			let appTag = CodePieceApplication.hashtag
			
			hashtags.removeAll { $0 == appTag }
			hashtags.append(appTag)
		}
		
		return hashtags
	}
	
	func makeDescriptionWithEffectiveHashtags(hashtags: [Hashtag], appendString:String? = nil) -> String {
		
//		func getTruncatedDescription(_ description: String, maxLength: Int) -> String {
//
//			let descriptionLength = Int(ceil(Double(maxLength) - hashtags.twitterDisplayTextLength))
//
//			guard description.count > descriptionLength else {
//
//				return description
//			}
//
//			let sourceDescription = description
//
//			let start = sourceDescription.startIndex
//			let end = sourceDescription.index(start, offsetBy: descriptionLength - 2)
//
//			return String(sourceDescription.prefix(through: end)) + " …"
//		}
		
		func getDescription() -> String {

//			if let maxLength = maxLength {
//
//				return getTruncatedDescription(data.description, maxLength: maxLength)
//			}
//			else {
				
				return data.description
//			}
		}
		
		return getDescription()
			.appendStringIfNotEmpty(string: appendString, separator: " ")
			.appendStringIfNotEmpty(string: hashtags.twitterDisplayText, separator: " ")
	}
}
