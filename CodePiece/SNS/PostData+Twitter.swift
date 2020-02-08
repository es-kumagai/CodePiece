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
				var uri = String(result[Range(match.range(at: 4), for: result)])
				var query = String(result[Range(match.range(at: 5), for: result)])

				let uriPattern = try! NSRegularExpression(pattern: #"[^\/\.]+"#)
				let queryPattern = try! NSRegularExpression(pattern: #"[^=&]+"#)
				
				/// When non-escaped character is found in text, consider '%' is not escaped.
				func needsToEscape(_ text: String) -> Bool {
					
					var text = text
					
					let escapedPattern = try! NSRegularExpression(pattern: #"%\d\d"#)
					let allowedWordPattern = try! NSRegularExpression(pattern: #"[A-Za-z0-9-_\.\?:#/@%!\$&'\(\)\*\+,;=~]"#)
					
					escapedPattern.replaceAllMatches(on: &text, with: "")
					allowedWordPattern.replaceAllMatches(on: &text, with: "")
					
					print(text, text.isEmpty)
					return !text.isEmpty
				}

				for match in uriPattern.matches(in: uri, options: [], range: NSRange(location: 0, length: uri.count)).reversed() {

					let range = Range(match.range, for: uri)
					let item = String(uri[range])

					guard needsToEscape(item) else {
						
						continue
					}
					
					uri = uri.replacingCharacters(in: range, with: item.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)
				}

				for match in queryPattern.matches(in: query, options: [], range: NSRange(location: 0, length: query.count)).reversed() {

					let range = Range(match.range, for: query)
					let item = String(query[range])

					guard needsToEscape(item) else {
						
						continue
					}
					
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
