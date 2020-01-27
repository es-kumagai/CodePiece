//
//  TweetMode.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/01/27.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Swifter

internal typealias SwifterTweetMode = TweetMode

extension API {

	public enum TweetMode {
    
		case `default`
		case extended
		case compat
		case other(String)
	}
}

extension API.TweetMode : RawRepresentable {

	public var rawValue: String {
	
		switch self {
			
		case .default:
			return ""
			
		case .extended:
			return "extended"
			
		case .compat:
			return "compat"
			
		case .other(let value):
			return value
		}
	}
	
	public init(rawValue value: String) {
		
		switch value {
			
		case "":
			self = .default
			
		case "extended":
			self = .extended
			
		case "compat":
			self = .compat
			
		default:
			self = .other(value)
		}
	}
}

internal extension API.TweetMode {
	
	init(_ rawMode: SwifterTweetMode) {
		
		switch rawMode {
			
		case .default:
			self = .default
			
		case .extended:
			self = .extended
			
		case .compat:
			self = .compat
			
		case .other(let value):
			self = .other(value)
		}
	}
}

// MARK: - Swifter's TweetMode

extension SwifterTweetMode {

	init(_ mode: API.TweetMode) {
		
		switch mode {
			
		case .default:
			self = .default
			
		case .extended:
			self = .extended
			
		case .compat:
			self = .compat
			
		case .other(let value):
			self = .other(value)
		}
	}
}
