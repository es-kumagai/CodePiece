//
//  Extension.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/08.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import Swim

public protocol ReferenceDateConvertible {
	
	init(timeIntervalSinceReferenceDate: NSTimeInterval)
	var timeIntervalSinceReferenceDate: NSTimeInterval { get }
}

extension ReferenceDateConvertible {
	
	public static func timeIntervalSinceReferenceDate(instance:Self) -> () -> NSTimeInterval {
		
		return { instance.timeIntervalSinceReferenceDate }
	}
}

extension ReferenceDateConvertible {
	
	public init(_ date:NSDate) {
		
		self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
	}
	
	public init?(_ dateComponents:NSDateComponents) {
		
		guard let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents) else {
			
			return nil
		}
		
		self.init(date)
	}
	
	public func toNSDate() -> NSDate {
		
		let date = NSDate()
		
		date.timeIntervalSinceReferenceDate
		return NSDate(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate)
	}
	
	public func toNSDateComponentsWithFlag(unitFlags: NSCalendarUnit) -> NSDateComponents {
		
		return NSCalendar.currentCalendar().components(unitFlags, fromDate: self.toNSDate())
	}
	
	public func toNSDateComponents() -> NSDateComponents {
		
		return self.toNSDateComponentsWithFlag(NSCalendarUnit(rawValue: UInt.max))
	}
}

public protocol DateCalculatable {
	
	typealias DateType = Self
	
	var midnight:DateType { get }
	var yesterday:DateType { get }

	func yearsAgo(years:Int) -> DateType
	func monthsAgo(months:Int) -> DateType
	func daysAgo(days:Int) -> DateType
	func hoursAgo(hours:Int) -> DateType
	func minutesAgo(minutes:Int) -> DateType
	func secondsAgo(seconds:Int) -> DateType
	func nanosecondsAgo(nanoseconds:Int) -> DateType
	
	func yearsAfter(years:Int) -> DateType
	func monthsAfter(months:Int) -> DateType
	func daysAfter(days:Int) -> DateType
	func hoursAfter(hours:Int) -> DateType
	func minutesAfter(minutes:Int) -> DateType
	func secondsAfter(seconds:Int) -> DateType
	func nanosecondsAfter(nanoseconds:Int) -> DateType
}

extension DateCalculatable {

	static func midnight(instance: Self) -> () -> DateType {
		
		return { instance.midnight }
	}
	
	static func yesterday(instance: Self) -> () -> DateType {
		
		return { instance.yesterday }
	}
}

extension DateCalculatable where Self : ReferenceDateConvertible, Self == DateType {
	
	public var midnight:DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.hour = 0
			target.minute = 0
			target.second = 0
			target.nanosecond = 0
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `years` years ago from `self`.
	public func yearsAgo(years:Int) -> DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.year -= years
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `months` months ago from `self`.
	public func monthsAgo(months:Int) -> DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.month -= months
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `days` days ago from `self`.
	public func daysAgo(days:Int) -> DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.day -= days
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `hours` hours ago from `self`.
	public func hoursAgo(hours:Int) -> DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.hour -= hours
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `minutes` minutes ago from `self`.
	public func minutesAgo(minutes:Int) -> DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.minute -= minutes
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `seconds` seconds ago from `self`.
	public func secondsAgo(seconds:Int) -> DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.second -= seconds
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `nanoseconds` nanoseconds ago from `self`.
	public func nanosecondsAgo(nanoseconds:Int) -> DateType {
		
		let components = tweak(self.toNSDateComponents()) { target -> NSDateComponents in
			
			target.nanosecond -= nanoseconds
			
			return target
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `years` years after from `self`.
	public func yearsAfter(years:Int) -> DateType {
		
		return self.yearsAgo(-years)
	}
	
	/// Returns a date which `months` months after from `self`.
	public func monthsAfter(months:Int) -> DateType {
		
		return self.monthsAgo(-months)
	}
	
	/// Returns a date which `days` days after from `self`.
	public func daysAfter(days:Int) -> DateType {
		
		return self.daysAgo(-days)
	}
	
	/// Returns a date which `hours` hours after from `self`.
	public func hoursAfter(hours:Int) -> DateType {
		
		return self.hoursAgo(-hours)
	}
	
	/// Returns a date which `minutes` minutes after from `self`.
	public func minutesAfter(minutes:Int) -> DateType {
		
		return self.minutesAgo(-minutes)
	}
	
	/// Returns a date which `seconds` seconds after from `self`.
	public func secondsAfter(seconds:Int) -> DateType {
		
		return self.secondsAgo(-seconds)
	}
	
	/// Returns a date which `nanoseconds` nanoseconds after from `self`.
	public func nanosecondsAfter(nanoseconds:Int) -> DateType {
		
		return self.nanosecondsAgo(-nanoseconds)
	}
	
	/// Returns a date which means yesterday (a second ago from midnight of `self`)
	public var yesterday:DateType {
		
		return self.midnight.nanosecondsAgo(1)
	}
}

extension NSDate : DateCalculatable, ReferenceDateConvertible {
	
	public typealias DateType = NSDate
}
