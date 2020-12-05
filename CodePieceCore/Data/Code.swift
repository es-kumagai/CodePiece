//
//  Code.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/05/22.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

/// プログラムコードを保持するデータ型です。
public struct Code {
	
	/// プログラムコードを行単位で保持します。各行は開業で終わります。
	public var newlineTerminatedLines: Array<String>
	
	/// プログラムコードを行単位のシーケンスで受け取って初期化します。
	/// - Parameter lines: プログラムコードです。各行は改行で終わります。
	public init<S: Sequence>(newlineTerminatedLines lines: S) where S.Element : StringProtocol {
		
		newlineTerminatedLines = lines.map(String.init(_:))
	}
}

extension Code : LosslessStringConvertible {
	
	/// ソースコード文字列から初期化します。
	/// - Parameter code: ソースコードです。
	public init(_ code: String) {

		newlineTerminatedLines = code.split(separator: "\n", omittingEmptySubsequences: false).map { $0 + "\n" }
	}
	
	/// コードが空だった時に `true` を返します。
	public var isEmpty: Bool {
		
		return newlineTerminatedLines.allSatisfy {
			
			$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		}
	}
	
	/// コードを文字列で表現します。
	public var description: String {
		
		guard !isEmpty else {
			
			return ""
		}
		
		return normalizedIndentation(of: newlineTerminatedLines).joined()
	}
}

private extension Code {
	
	/// いちばん低いインデントレベルをインデントなしとみなして、インデントを正規化します。
	/// - Parameter lines: 正規化する対象のコードです。
	/// - Returns: 正規化されたコードを返します。
	func normalizedIndentation<T:Sequence>(of lines: T) -> [String] where T.Element == String {
		
		/// ソースコードの各行で、いちばん冒頭のスペースが少ない行の冒頭スペース数を取得します。
		/// - Parameter lines: 対象のソースコードです。
		/// - Returns: いちばん少なかった冒頭のスペース数です。
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
		
		/// 不必要なインデントを削除します。
		/// - Parameters:
		///   - lines: 対象のソースコードです。
		///   - indentCount: 削除するインデントのスペース数です。
		/// - Returns: 不必要なインデントを削除したソースコードです。
		func trimmedIndentation(from lines: [String], indentCount: Int) -> [String] {
			
			guard indentCount > 0 else {
				
				return lines
			}
			
			let pattern = "^\(String(repeating: " ", count: indentCount))"
			
			return lines.map { line in
				
				return line.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: line.startIndex ..< line.endIndex)
			}
		}
		
		let lines = lines.replacingTabToSpace(spacesPerTab: 4)
		let indentCount = minimumCountOfSpace(lines)
		
		return trimmedIndentation(from: lines, indentCount: indentCount)
	}

}
