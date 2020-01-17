//
//  Date.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation

public struct Date : RawRepresentable {
	
	public var rawValue: Foundation.Date
	
	public init() {
	
		self.init(Foundation.Date())
	}
	
	public init(rawValue: Foundation.Date) {
		
		self.rawValue = rawValue
	}
}

extension Date {
	
	public static func date(fromTwitterDateString string: String) -> Foundation.Date? {

		let formatter = DateFormatter()
		
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "EEE MM dd HH:mm:ss Z yyyy"
		
		return formatter.date(from: string)
	}
}

extension Date {
	
	public init(_ date: Foundation.Date) {
		
		self.rawValue = date
	}
	
	public init?(_ string: String) {
		
		guard let date = Date.date(fromTwitterDateString: string) else {
			
			return nil
		}
		
		self.rawValue = date
	}
}

extension Date : DateCalculatable, ReferenceDateConvertible {

	public typealias DateType = Self
	
	public init(timeIntervalSinceReferenceDate: TimeInterval) {
	
		self.init(Foundation.Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate))
	}

	public var timeIntervalSinceReferenceDate: TimeInterval {
	
		return self.rawValue.timeIntervalSinceReferenceDate
	}
}

extension Date : Comparable {
	
}

public func == (lhs: Date, rhs: Date) -> Bool {
	
	return lhs.rawValue == rhs.rawValue
}

public func < (lhs: Date, rhs: Date) -> Bool {
	
	return lhs.rawValue < rhs.rawValue
}

extension Date : Decodable {
	
	public init(from decoder: Decoder) throws {
	
		let container = try decoder.singleValueContainer()
		
		rawValue = try container.decode(Foundation.Date.self)
	}
}

extension Date : CustomStringConvertible {
	
	public var description:String {
		
		return rawValue.description
	}
}
