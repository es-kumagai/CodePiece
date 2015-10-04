//
//  Color.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki
import AppKit

public struct Color : RawRepresentable {
	
	public var rawValue: NSColor
	
	public enum InitializeError : ErrorType {
		
		case InvalidFormat(String)
	}
	
	public init(rawValue: NSColor) {
		
		self.rawValue = rawValue
	}
}

extension Color.InitializeError : CustomStringConvertible {

	public var description: String {
		
		switch self {
			
		case let .InvalidFormat(string):
			return "Color Initialize Error : Invalid Format (\(string))"
		}
	}
}

extension Color {
	
	public init(twitterColorString string: String) throws {

		guard string.characters.count == 6 else {
			
			throw InitializeError.InvalidFormat(string)
		}

		enum ColorPartLocation : Int {
			
			case Red = 0
			case Green = 2
			case Blue = 4
		}
		
		let getColorPart = { (part:ColorPartLocation) -> String in

			let location = part.rawValue
			return string.substringWithRange(string.startIndex.advancedBy(location) ... string.startIndex.advancedBy(location + 1))
		}
		
		let toColorElement = { (part:String) throws -> CGFloat in
			
			guard part.characters.count == 2, let value = Int(part, radix: 16) else {
				
				throw InitializeError.InvalidFormat(string)
			}
			
			return CGFloat(value) / 255.0
		}

		let red = try toColorElement(getColorPart(.Red))
		let green = try toColorElement(getColorPart(.Green))
		let blue = try toColorElement(getColorPart(.Blue))

		self.rawValue = NSColor(red: red, green: green, blue: blue, alpha: 1.0)
	}
}

extension Color : Decodable {

	public static func decode(e: Extractor) throws -> Color {
		
		let string = try String.decode(e)
		
		do {

			return try Color(twitterColorString: string)
		}
		catch is InitializeError {
			
			throw DecodeError.TypeMismatch(expected: "\(Color.self)", actual: "\(string)", keyPath: nil)
		}
	}
}
