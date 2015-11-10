//
//  Date.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki
import Foundation

public struct Date : RawRepresentable {
	
	public var rawValue:NSDate
	
	public init() {
	
		self.init(NSDate())
	}
	
	public init(rawValue: NSDate) {
		
		self.rawValue = rawValue
	}
}

extension NSDate {
	
	public static func dateFromTwitterDateString(string: String) -> NSDate? {

		let formatter = NSDateFormatter()
		
		formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		formatter.dateFormat = "EEE MM dd HH:mm:ss Z yyyy"
		
		return formatter.dateFromString(string)
	}
}

extension Date {
	
	public init(_ date:NSDate) {
		
		self.rawValue = date
	}
	
	public init?(_ string:String) {
		
		guard let date = NSDate.dateFromTwitterDateString(string) else {
			
			return nil
		}
		
		self.rawValue = date
	}
}

extension Date : DateCalculatable, ReferenceDateConvertible {

	public typealias DateType = Date
	
	public init(timeIntervalSinceReferenceDate: NSTimeInterval) {
	
		self.init(NSDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate))
	}

	public var timeIntervalSinceReferenceDate: NSTimeInterval {
	
		return self.rawValue.timeIntervalSinceReferenceDate
	}
}

extension Date : Comparable {
	
}

public func == (lhs:Date, rhs:Date) -> Bool {
	
	return lhs.rawValue.isEqualToDate(rhs.rawValue)
}

public func < (lhs:Date, rhs:Date) -> Bool {
	
	return lhs.rawValue.compare(rhs.rawValue) == NSComparisonResult.OrderedAscending
}

extension Date : Decodable {
	
	public static func decode(e: Extractor) throws -> Date {
		
		let string = try String.decode(e)
		
		guard let result = Date(string) else {
			
			throw DecodeError.TypeMismatch(expected: "\(DecodedType.self)", actual: "\(string)", keyPath: nil)
		}
		
		return result
	}
}

extension Date : CustomStringConvertible {
	
	public var description:String {
		
		return self.rawValue.description
	}
}
