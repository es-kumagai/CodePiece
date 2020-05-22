//
//  Code.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/05/22.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

public struct Code {
	
	public var newlineTerminatedLines: Array<String>
	
	public init<S: Sequence>(newlineTerminatedLines lines: S) where S.Element : StringProtocol {
		
		newlineTerminatedLines = lines.map(String.init(_:))
	}
}

extension Code : CustomStringConvertible {
	
	public init(_ code: String?) {

		guard let code = code else {
			
			newlineTerminatedLines = []
			return
		}
		
		guard !code.trimmingCharacters(in: .whitespaces).isEmpty else {
			
			newlineTerminatedLines = []
			return
		}
		
		newlineTerminatedLines = code.split(separator: "\n").map { $0 + "\n" }
	}
	
	public var isEmpty: Bool {
		
		return newlineTerminatedLines.isEmpty
	}
	
	public var description: String {
		
		guard !isEmpty else {
			
			return ""
		}
		
		return normalizedIndentation(of: newlineTerminatedLines).joined()
	}
}

private extension Code {
	
	func normalizedIndentation<T:Sequence>(of lines: T) -> [String] where T.Element == String {
		
		func replacingTabToSpace(_ lines: T, spacesPerTab: Int) -> [String] {

			lines.map {
				
				$0.replacingOccurrences(of: "\t", with: String(repeating: " ", count: spacesPerTab))
			}
		}
		
		func minimumCountOfSpace(_ lines: [String]) -> Int {
			
			let emptyPattern = try! NSRegularExpression(pattern: ##"^\s*\n$"##)
			let indentPattern = try! NSRegularExpression(pattern: ##"^( *)"##)
			
			let counts = lines.compactMap { line -> Int? in
				
				let lineRange = NSRange(location: 0, length: line.count)
				
				guard emptyPattern.firstMatch(in: line, range: lineRange) == nil else {
				
					return nil
				}
				
				guard let match = indentPattern.firstMatch(in: line, range: NSRange(location: 0, length: line.count)) else {
					
					return nil
				}
				
				return match.range.length
			}
			
			return counts.min() ?? 0
		}
		
		func trimmedIndentation(from lines: [String], indentCount: Int) -> [String] {
			
			guard indentCount > 0 else {
				
				return lines
			}
			
			let pattern = "^\(String(repeating: " ", count: indentCount))"
			
			return lines.map { line in
				
				return line.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: line.startIndex ..< line.endIndex)
			}
		}
		
		let lines = replacingTabToSpace(lines, spacesPerTab: 4)
		let indentCount = minimumCountOfSpace(lines)
		
		return trimmedIndentation(from: lines, indentCount: indentCount)
	}

}
