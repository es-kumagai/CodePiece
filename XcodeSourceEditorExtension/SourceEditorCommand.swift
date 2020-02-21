//
//  SourceEditorCommand.swift
//  XcodeSourceEditorExtension
//
//  Created by Tomohiro Kumagai on 2020/02/21.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import XcodeKit

class SendToCodePieceCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

		guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
			
			completionHandler(nil)
			return
		}
		
		guard let lines = invocation.buffer.lines as? [String] else {
		
			completionHandler(NSError(.failedToOpenCodePiece("Unexpected lines selected: \(selection)")))
			return
		}
		
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
		
		let codes = lines[selection.start.line ... selection.end.line]
		let code = normalizedIndentation(of: codes).joined()
		
		guard !code.isEmpty else {
			
			completionHandler(nil)
			return
		}
		
		let scheme = CodePieceUrlScheme(method: "open", language: "Swift", code: code)

		guard let url = URL(scheme) else {
			
			completionHandler(NSError(.failedToOpenCodePiece("Failed to create URL scheme for CodePiece.")))
			return
		}
		
		NSLog("Try opening CodePiece app using URL scheme: %@", url.absoluteString)

		switch NSWorkspace.shared.open(url) {
			
		case true:
			completionHandler(nil)

		case false:
			completionHandler(NSError(.failedToOpenCodePiece("Failed to open CodePiece (\(url.absoluteString))")))
		}
    }
    
}
