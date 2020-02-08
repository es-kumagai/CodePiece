//
//  PostDataExtensionForTwitter.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/11/24.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import ESGists
import ESTwitter

extension PostData {
}

extension PostDataContainer.TwitterState {
	
	var isPosted: Bool {
		
		return postedStatus != nil
	}
}

extension PostDataContainer {
	
	var isPostedToTwitter: Bool {
		
		return twitterState.isPosted
	}
	
	var appendAppTagToTwitter: Bool {
		
		return data.appendAppTagToTwitter
	}
	
	var appendLangTagToTwitter: Bool {
		
		return hasCode
	}

	var postedTwitterText: String? {
		
		return twitterState.postedStatus?.text
	}
	
	func descriptionLengthForTwitter(includesGistsLink:Bool) -> Int {

		let countsForGistsLink = includesGistsLink ? Twitter.SpecialCounting.media.length + Twitter.SpecialCounting.httpsUrl.length + 2 : 0

		return Int(makeDescriptionForTwitter(forCountingLength: true).twitterCharacterView.wordCountForPost + countsForGistsLink)
	}
	
	func makeDescriptionForTwitter(forCountingLength: Bool = false) -> String {
		
		func replacingDescriptionWithPercentEscapingUrl(_ text: String) -> String {
			
			var result = text
			
			let urlPattern = try! NSRegularExpression(pattern:
				#"(?:^|\s)((http(?:s|)):\/\/([^\/]+)/([^\?]*)\?(.+?))(?:\s|$)"#
				, options: [])

			for match in urlPattern.matches(in: result, options: [], range: NSRange(location: 0, length: text.count)).reversed() {
				
				let targetRange = Range(match.range(at: 1), for: result)
				
				let scheme = String(result[Range(match.range(at: 2), for: result)])
				let host = String(result[Range(match.range(at: 3), for: result)])
				let uri = String(result[Range(match.range(at: 4), for: result)])
				var query = String(result[Range(match.range(at: 5), for: result)])

				let queryPattern = try! NSRegularExpression(pattern: #"[^=&]+"#)
				
				for match in queryPattern.matches(in: query, options: [], range: NSRange(location: 0, length: query.count)).reversed() {
					
					let range = Range(match.range, for: query)
					let item = String(query[range])
					
					query = query.replacingCharacters(in: range, with: item.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
				}
				
				result = result.replacingCharacters(in: targetRange, with: "\(scheme)://\(host)/\(uri)?\(query)")
			}
			
			return result
		}
		
		func replacingDescriptionWithUrlToDummyText(_ text: String) -> String {
			
			var result = text
			
			let urlWord = #"A-Za-z0-9-_\.\?:#/@%!\$&'\(\)\*\+,;=~"#
			let urlPattern = try! NSRegularExpression(pattern: #"(^|\s)(http(s|):\/\/[\#(urlWord)]+)(\s|$)"#, options: [])

			for match in urlPattern.matches(in: result, options: [], range: NSRange(location: 0, length: text.count)).reversed() {
				
				let range = match.range(at: 2)

				result = result.replacingCharacters(in: Range(range, for: result), with: "xxxxxxxxxxxxxxxxxxxxxxx")
			}
			
			return result
		}

		let description = makeDescriptionWithEffectiveHashtags(hashtags: effectiveHashtagsForTwitter, appendString: gistPageUrl)
		
		let escapedDescription = replacingDescriptionWithPercentEscapingUrl(description)
		
		DebugTime.print("Escaped description: \(escapedDescription)")
		switch forCountingLength {
						
		case true:
			return replacingDescriptionWithUrlToDummyText(escapedDescription)

		case false:
			return escapedDescription
		}
	}
	
	var effectiveHashtagsForTwitter: [Hashtag] {
		
		return effectiveHashtags(withAppTag: appendAppTagToTwitter, withLangTag: appendLangTagToTwitter)
	}
}
