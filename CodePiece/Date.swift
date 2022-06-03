//
//  Date.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/08/12.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

@preconcurrency import struct Foundation.Date
import class Foundation.DateFormatter
import struct Foundation.Calendar

private let formatter: DateFormatter = {

	let calendar = Calendar.current
	let formatter = DateFormatter()
	
	formatter.calendar = calendar
	formatter.dateStyle = .short
	formatter.timeStyle = .medium
	
	return formatter
}()

/// A standard date type for CodePiece.
struct Date : Sendable {
	
	var rawDate: Foundation.Date
	
	init(_ rawDate: Foundation.Date) {
		
		self.rawDate = rawDate
	}
}

extension Date {

	init() {
		
		self.init(Foundation.Date())
	}
}

extension Date : Hashable {
	
}

extension Date : Comparable {
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		
		lhs.rawDate < rhs.rawDate
	}
}

extension Date : CustomStringConvertible {
	
	var description: String {
		
		formatter.string(from: rawDate)
	}
}
