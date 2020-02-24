//
//  SendToCodePieceCommand.swift
//  XcodeSourceEditorExtension
//
//  Created by Tomohiro Kumagai on 2020/02/21.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import XcodeKit

class OpenCodePieceCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

		let scheme = CodePieceUrlScheme(method: "open")

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
