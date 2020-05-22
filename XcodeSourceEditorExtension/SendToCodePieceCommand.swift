//
//  SendToCodePieceCommand.swift
//  XcodeSourceEditorExtension
//
//  Created by Tomohiro Kumagai on 2020/02/21.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import XcodeKit
import CodePieceCore

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
				
		var endLine: Int {
			
			switch selection.end.column {
				
			case 0:
				return selection.end.line - 1
				
			default:
				return selection.end.line
			}
		}
		
		let startLine = selection.start.line
		
		let codes = lines[startLine ... endLine]
		let code = Code(newlineTerminatedLines: codes)
		
		guard !code.isEmpty else {
			
			completionHandler(nil)
			return
		}
		
		let scheme = CodePieceUrlScheme(method: "open", language: "Swift", code: code.description)

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
