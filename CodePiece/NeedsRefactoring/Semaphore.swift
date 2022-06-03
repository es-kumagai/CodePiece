//
//  Semaphore.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/11/27.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Foundation

public final class Semaphore : RawRepresentable, @unchecked Sendable {

	public enum WaitResult<Success : Sendable, Failure : Error> : Sendable {
	
		case success(Success)
		case failure(Failure)
		case timeout
	}
	
	@available(*, unavailable, message: "Use `DispatchTime` instead.")
	public struct Time {
	
//		public var rawValue: dispatch_time_t
//
//		public init() {
//
//			self.rawValue = DISPATCH_TIME_NOW
//		}
//
//		public init(rawValue time:dispatch_time_t) {
//
//			self.rawValue = time
//		}
//
//		public func delta(second time:Double) -> Time {
//
//			return Time(rawValue: dispatch_time(self.rawValue, Interval(second: time).rawValue))
//		}
//
//		public func delta(millisecond time:Double) -> Time {
//
//			return Time(rawValue: dispatch_time(self.rawValue, Interval(millisecond: time).rawValue))
//		}
//
//		public func delta(microsecond time:Double) -> Time {
//
//			return Time(rawValue: dispatch_time(self.rawValue, Interval(microsecond: time).rawValue))
//		}
//
//		public func delta(nanosecond time:Int64) -> Time {
//
//			return Time(rawValue: dispatch_time(self.rawValue, Interval(nanosecond: time).rawValue))
//		}
	}
	
	public struct Interval : Sendable {
		
		static var zero = Interval(nanosecond: 0)
		
		public var nanoseconds: Int
		
		public init(second value: Double) {
			
			nanoseconds = Int(value * Double(NSEC_PER_SEC))
		}
		
		public init(millisecond value: Double) {
			
			nanoseconds = Int(value * Double(NSEC_PER_MSEC))
		}
		
		public init(microsecond value:Double) {
			
			nanoseconds = Int(value * Double(NSEC_PER_USEC))
		}
		
		public init(nanosecond value: Int) {
			
			nanoseconds = value
		}
		
		public var second: Double {
			
			Double(nanoseconds) / Double(NSEC_PER_SEC)
		}
		
		public var millisecond: Double {
			
			Double(nanoseconds) / Double(NSEC_PER_MSEC)
		}
		
		public var microsecond: Double {
			
			Double(nanoseconds) / Double(NSEC_PER_USEC)
		}
	}
	
	private nonisolated let semaphore: DispatchSemaphore
	
	public init(value: Int = 0) {
		
		semaphore = DispatchSemaphore(value: value)
	}
	
	public required init(rawValue rawSemaphore: DispatchSemaphore) {
		
		semaphore = rawSemaphore
	}
	
	public var rawValue: DispatchSemaphore {
		
		semaphore
	}
	
	public func wait() {
		
		wait(timeout: .distantFuture)
	}
	
	@discardableResult
	public func wait(timeout: DispatchTime) -> DispatchTimeoutResult {
		
		semaphore.wait(timeout: timeout)
	}
	
	public func signal() {
		
		semaphore.signal()
	}

	@discardableResult
	public func invokeWithBlocking<Success : Sendable>(on queue: DispatchQueue? = nil, timeout: DispatchTime = .distantFuture, operation: @escaping @Sendable () async -> Success) -> WaitResult<Success, Never> {
		
		let result = invokeWithThrowingBlocking(on: queue, timeout: timeout) { () async throws -> Success in
			
			await operation()
		}
		
		switch result {
			
		case .success(let value):
			return .success(value)
			
		case .timeout:
			return .timeout
			
		case .failure(let error):
			fatalError("Unexpected error has been occurred: \(error)")
		}
	}
	
	@discardableResult
	public func invokeWithThrowingBlocking<Success : Sendable>(on queue: DispatchQueue? = nil, timeout: DispatchTime = .distantFuture, operation: @escaping @Sendable () async throws -> Success) -> WaitResult<Success, Error> {

		let result = BlockingResult<Success, Error>()
		
		Task.detached {
			
			defer {
			
				self.signal()
			}
		
			do {

				result.value = try await .success(operation())
			}
			catch {
				
				result.value = .failure(error)
			}
		}
	
		switch wait(timeout: timeout) {
			
		case .success:
			return result.value
			
		case .timedOut:
			return .timeout
		}
	}
//	
//	public func executeOnQueue(queue: DispatchQueue, timeout: DispatchTime = .distantFuture, body: @escaping (WaitResult) -> Void) {
//		
//		queue.async { [unowned self] in
//			
//			switch wait(timeout: timeout) {
//				
//			case .success:
//				
//				defer {
//					
//					signal()
//				}
//				
//				body(.success)
//				
//				
//			case .timeout:
//			
//				body(.timeout)
//			}
//		}
//	}
}

private extension Semaphore {
	
	final class BlockingResult<Success : Sendable, Failure : Error> : @unchecked Sendable {

		var value: WaitResult<Success, Failure>!
	}
}

extension Semaphore.WaitResult {
	
	public var isTimedOut: Bool {
		
		switch self {
			
		case .timeout:
			return true
			
		case .success, .failure:
			return false
		}
	}
	
	public func get() throws -> Success! {
		
		switch self {
			
		case .success(let value):
			return value
			
		case .failure(let error):
			throw error
			
		case .timeout:
			return nil
		}
	}
}

extension Semaphore.WaitResult where Failure == Never {
	
	public var value: Success! {
		
		switch self {
			
		case .success(let value):
			return value
			
		case .failure, .timeout:
			return nil
		}
	}
}

extension Semaphore.Interval {
	
	static func +(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Semaphore.Interval {
		
		Semaphore.Interval(nanosecond: lhs.nanoseconds + rhs.nanoseconds)
	}
	
	static func -(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Semaphore.Interval {
		
		Semaphore.Interval(nanosecond: lhs.nanoseconds - rhs.nanoseconds)
	}
	
	static func *(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Semaphore.Interval {
		
		Semaphore.Interval(nanosecond: lhs.nanoseconds * rhs.nanoseconds)
	}
	
	static func /(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Semaphore.Interval {
		
		Semaphore.Interval(nanosecond: lhs.nanoseconds / rhs.nanoseconds)
	}
}

extension Semaphore.Interval : Comparable {

	public static func ==(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Bool {
		
		lhs.nanoseconds == rhs.nanoseconds
	}

	public static func !=(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Bool {
		
		lhs.nanoseconds != rhs.nanoseconds
	}

	public static func <(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Bool {
		
		lhs.nanoseconds < rhs.nanoseconds
	}

	public static func >(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Bool {
		
		lhs.nanoseconds > rhs.nanoseconds
	}

	public static func <=(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Bool {
		
		lhs.nanoseconds <= rhs.nanoseconds
	}

	public static func >=(lhs: Semaphore.Interval, rhs: Semaphore.Interval) -> Bool {
		
		lhs.nanoseconds >= rhs.nanoseconds
	}
}

extension Semaphore.Interval : CustomStringConvertible {

	public var description: String {
		
		String(second)
	}
}

extension DispatchTime {
	
	static func +(lhs: DispatchTime, rhs: Semaphore.Interval) -> DispatchTime {
		
		lhs + DispatchTimeInterval.nanoseconds(rhs.nanoseconds)
	}
}
