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
	
	init(timeIntervalSinceReferenceDate: TimeInterval)
	var timeIntervalSinceReferenceDate: TimeInterval { get }
}

extension ReferenceDateConvertible {
	
	public static func timeIntervalSinceReferenceDate(instance:Self) -> () -> TimeInterval {
		
		return { instance.timeIntervalSinceReferenceDate }
	}
}

extension ReferenceDateConvertible {
	
	public init(_ date: Foundation.Date) {
		
		self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
	}
	
	public init?(_ dateComponents: DateComponents) {
		
		guard let date = NSCalendar.current.date(from: dateComponents) else {
			
			return nil
		}
		
		self.init(date)
	}
	
	public func toFoundationDate() -> Foundation.Date {
		
		let date = Foundation.Date()
		
		return Foundation.Date(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate)
	}
	
	public func toFoundationDateComponentsWithFlag(unitFlags: NSCalendar.Unit) -> DateComponents {
		
		return NSCalendar.current.components(unitFlags, from: self.toFoundationDate())
	}
	
	public func toFoundationDateComponents() -> DateComponents {
		
		return toFoundationDateComponentsWithFlag(unitFlags: NSCalendar.Unit(rawValue: UInt.max))
	}
}

public protocol DateCalculatable {
	
	associatedtype DateType = Self
	
	var midnight:DateType { get }
	var yesterday:DateType { get }

	func yearsAgo(_ years:Int) -> DateType
	func monthsAgo(_ months:Int) -> DateType
	func daysAgo(_ days:Int) -> DateType
	func hoursAgo(_ hours:Int) -> DateType
	func minutesAgo(_ minutes:Int) -> DateType
	func secondsAgo(_ seconds:Int) -> DateType
	func nanosecondsAgo(_ nanoseconds:Int) -> DateType
	
	func yearsAfter(_ years:Int) -> DateType
	func monthsAfter(_ months:Int) -> DateType
	func daysAfter(_ days:Int) -> DateType
	func hoursAfter(_ hours:Int) -> DateType
	func minutesAfter(_ minutes:Int) -> DateType
	func secondsAfter(_ seconds:Int) -> DateType
	func nanosecondsAfter(_ nanoseconds:Int) -> DateType
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
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.hour = 0
			target.minute = 0
			target.second = 0
			target.nanosecond = 0
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `years` years ago from `self`.
	public func yearsAgo(_ years:Int) -> DateType {
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.year? -= years
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `months` months ago from `self`.
	public func monthsAgo(_ months:Int) -> DateType {
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.month? -= months
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `days` days ago from `self`.
	public func daysAgo(_ days:Int) -> DateType {
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.day? -= days
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `hours` hours ago from `self`.
	public func hoursAgo(_ hours:Int) -> DateType {
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.hour? -= hours
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `minutes` minutes ago from `self`.
	public func minutesAgo(_ minutes:Int) -> DateType {
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.minute? -= minutes
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `seconds` seconds ago from `self`.
	public func secondsAgo(_ seconds:Int) -> DateType {
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.second? -= seconds
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `nanoseconds` nanoseconds ago from `self`.
	public func nanosecondsAgo(_ nanoseconds:Int) -> DateType {
		
		let components = instanceApplyingExpression(with: toFoundationDateComponents()) { target in
			
			target.nanosecond? -= nanoseconds
		}
		
		return DateType(components)!
	}
	
	/// Returns a date which `years` years after from `self`.
	public func yearsAfter(_ years:Int) -> DateType {
		
		return self.yearsAgo(-years)
	}
	
	/// Returns a date which `months` months after from `self`.
	public func monthsAfter(_ months:Int) -> DateType {
		
		return self.monthsAgo(-months)
	}
	
	/// Returns a date which `days` days after from `self`.
	public func daysAfter(_ days:Int) -> DateType {
		
		return self.daysAgo(-days)
	}
	
	/// Returns a date which `hours` hours after from `self`.
	public func hoursAfter(_ hours:Int) -> DateType {
		
		return self.hoursAgo(-hours)
	}
	
	/// Returns a date which `minutes` minutes after from `self`.
	public func minutesAfter(_ minutes:Int) -> DateType {
		
		return self.minutesAgo(-minutes)
	}
	
	/// Returns a date which `seconds` seconds after from `self`.
	public func secondsAfter(_ seconds:Int) -> DateType {
		
		return self.secondsAgo(-seconds)
	}
	
	/// Returns a date which `nanoseconds` nanoseconds after from `self`.
	public func nanosecondsAfter(_ nanoseconds:Int) -> DateType {
		
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
