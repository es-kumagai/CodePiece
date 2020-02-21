//
//  SourceEditorCommand.swift
//  XcodeSourceEditorExtension
//
//  Created by Tomohiro Kumagai on 2020/02/21.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import XcodeKit

class SendToCodePieceCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
		let codes = invocation.buffer.selections.componentsJoined(by: "\n")
		
        completionHandler(nil)
    }
    
}
