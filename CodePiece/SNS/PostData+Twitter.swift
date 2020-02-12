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
	
	func descriptionLengthForTwitter(includesGistsLink: Bool) -> Int {

		let countsForGistsLink = includesGistsLink ? Twitter.SpecialCounting.media.length + Twitter.SpecialCounting.httpsUrl.length + 2 : 0

		return Int(makeDescriptionForTwitter(forCountingLength: true).twitterCharacterView.wordCountForPost + countsForGistsLink)
	}
	
	func makeDescriptionForTwitter(forCountingLength: Bool = false) -> String {
		
		func internalErrorUnexpectedRange<R>(_ range: NSRange, for text: String, note: String?, result: @autoclosure () -> R) -> R {

			let message = "Unexpected range '\(range)' for \(text) \(note != nil ? "(\(note!))" : "")"

			#if DEBUG
			fatalError(message)
			#else
			NSLog("INTERNAL ERROR: %@", message)
			return result()
			#endif
		}

		func replacingDescriptionWithPercentEscapingUrl(_ text: String) -> String {
			
			var result = text
						
			let urlPattern = try! NSRegularExpression(pattern:
				#"(?:^|\s)((http(?:s|)):\/\/([^\/\s]+?)/([^\?\s]*?)(?:|\?([^\s]*?)))(?:\s|$)"#
				, options: [])

			for match in urlPattern.matches(in: result, options: [], range: NSRange(location: 0, length: text.count)).reversed() {

				guard let targetRange = Range(match.range(at: 1), for: result) else {
					
					return internalErrorUnexpectedRange(match.range(at: 1), for: text, note: #function, result: text)
				}

				guard let schemeRange = Range(match.range(at: 2), for: result) else {
					
					return internalErrorUnexpectedRange(match.range(at: 2), for: text, note: #function, result: text)
				}

				guard let hostRange = Range(match.range(at: 3), for: result) else {
					
					return internalErrorUnexpectedRange(match.range(at: 3), for: text, note: #function, result: text)
				}

				let scheme = String(result[schemeRange])
				let host = String(result[hostRange])
				var uri = Range(match.range(at: 4), for: result).map { String(result[$0]) } ?? ""
				var query = Range(match.range(at: 5), for: result).map { String(result[$0]) } ?? ""

				let uriPattern = try! NSRegularExpression(pattern: #"[^\/\.]+"#)
				let queryPattern = try! NSRegularExpression(pattern: #"[^=&]+"#)
				
				/// When non-escaped character is found in text, consider '%' is not escaped.
				func needsToEscape(_ text: String) -> Bool {
					
					var text = text
					
					let escapedPattern = try! NSRegularExpression(pattern: #"%\d\d"#)
					let allowedWordPattern = try! NSRegularExpression(pattern: #"[A-Za-z0-9-_\.\?:#/@%!\$&'\(\)\*\+,;=~]"#)
					
					escapedPattern.replaceAllMatches(onto: &text, with: "")
					allowedWordPattern.replaceAllMatches(onto: &text, with: "")
					
					print(text, text.isEmpty)
					return !text.isEmpty
				}

				uriPattern.replaceAllMatches(onto: &uri) {

					guard needsToEscape($0) else {

						return $0
					}

					return $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
				}

				queryPattern.replaceAllMatches(onto: &query) {
					
					guard needsToEscape($0) else {

						return $0
					}

					return $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
				}

				// FIXME: ここのパッと見て複雑な印象を解消した。
				result = result.replacingCharacters(in: targetRange, with: "\(scheme)://\(host)/\(uri)\(query.isEmpty ? "" : "?")\(query)")
			}
			
			return result
		}
		
		func replacingDescriptionWithUrlToDummyText(_ text: String) -> String {
			
			var result = text
			
			let urlWord = #"A-Za-z0-9-_\.\?:#/@%!\$&'\(\)\*\+,;=~"#
			let urlPattern = try! NSRegularExpression(pattern:
				#"(^|\s)(http(s|):\/\/[\#(urlWord)]+)(\s|$)"#
				, options: [])

			urlPattern.replaceAllMatches(onto: &result) { item, range, match in
				
				guard let newRange = Range(match.range(at: 2), for: text) else {

					return internalErrorUnexpectedRange(match.range(at: 2), for: text, note: #function, result: item)
				}
				
				range = newRange
				return "xxxxxxxxxxxxxxxxxxxxxxx"
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
