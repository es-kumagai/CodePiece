//
//  TwitterDate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

@preconcurrency import struct Foundation.Date

public struct TwitterDate : RawRepresentable, Sendable {
	
	public var rawValue: Date
	
	public init() {
	
		self.init(Date())
	}
	
	public init(rawValue: Date) {
		
		self.rawValue = rawValue
	}
}

extension TwitterDate {
	
	public static func date(fromTwitterDateString string: String) -> Date? {

		let formatter = DateFormatter()
		
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "EEE MM dd HH:mm:ss Z yyyy"
		
		return formatter.date(from: string)
	}
}

extension TwitterDate {
	
	public init(_ date: Date) {
		
		rawValue = date
	}
	
	public init?(_ string: String) {
		
		guard let date = TwitterDate.date(fromTwitterDateString: string) else {
			
			return nil
		}
		
		rawValue = date
	}
}

extension TwitterDate : DateCalculatable, ReferenceDateConvertible {

	public typealias DateType = Self
	
	public init(timeIntervalSinceReferenceDate: TimeInterval) {
	
		self.init(Foundation.Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate))
	}

	public var timeIntervalSinceReferenceDate: TimeInterval {
	
		return rawValue.timeIntervalSinceReferenceDate
	}
}

extension TwitterDate : Comparable {
	
}

public func == (lhs: TwitterDate, rhs: TwitterDate) -> Bool {
	
	return lhs.rawValue == rhs.rawValue
}

public func < (lhs: TwitterDate, rhs: TwitterDate) -> Bool {
	
	return lhs.rawValue < rhs.rawValue
}

extension TwitterDate : Decodable {
	
	public init(from decoder: Decoder) throws {
	
		let container = try decoder.singleValueContainer()
		let dateString = try container.decode(String.self)
		
		guard let date = Self.date(fromTwitterDateString: dateString) else {
			
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
		}
		
		rawValue = date
	}
}

extension TwitterDate : CustomStringConvertible {
	
	private static let dateFormatter: DateFormatter = {
		
		let formatter = DateFormatter()
		
		formatter.locale = .current
		formatter.timeZone = .current
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		formatter.doesRelativeDateFormatting = true
		
		return formatter
	}()
	
	public var description: String {
		
		return Self.dateFormatter.string(from: rawValue)
	}
}
