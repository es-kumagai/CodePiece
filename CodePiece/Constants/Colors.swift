//
//  Colors.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit
import SwiftUI

extension NSColor {
	
	static let authenticatedForegroundColor = NSColor(named: "AuthenticatedForegroundColor")!
	static let authenticatedWithNoTokenForegroundColor = NSColor(named: "AuthenticatedWithNoTokenForegroundColor")!
	static let notAuthenticatedForegroundColor = NSColor(named: "NotAuthenticatedForegroundColor")!
	
	static let neutralColor = NSColor(named: "NeutralColor")!
	static let warningColor = NSColor(named: "WarningColor")!
	static let errorColor = NSColor(named: "ErrorColor")!
	static let attentionColor = NSColor(named: "AttentionColor")!
	
	static let textColor = NSColor(named: "TextColor")!
	static let optionTextColor = NSColor(named: "OptionTextColor")!
	static let recentBackgroundColor = NSColor(named: "RecentBackgroundColor")!
	static let pastBackgroundColor = NSColor(named: "PastBackgroundColor")!
	static let recentSelectionBackgroundColor = NSColor(named: "RecentSelectionBackgroundColor")!
	static let pastSelectionBackgroundColor = NSColor(named: "PastSelectionBackgroundColor")!
	static let urlColor = NSColor(named: "URLColor")!
	static let hashtagColor = NSColor(named: "HashtagColor")!
	static let mentionColor = NSColor(named: "MentionColor")!
	static let statusOkTextColor = NSColor(named: "StatusOkTextColor")!
	static let statusErrorTextColor = NSColor(named: "StatusErrorTextColor")!
	static let statusOkBackgroundColor = NSColor(named: "StatusOkBackgroundColor")!
	static let statusErrorBackgroundColor = NSColor(named: "StatusErrorBackgroundColor")!
}

extension Color {
	
	static let textColor = Color("TextColor")
	static let debugTextColor = Color("NeutralColor")
	static let warningColor = Color("WarningColor")
	static let errorColor = Color("ErrorColor")
	static let tryingColor = Color("TryingColor")
	static let successColor = Color("SuccessColor")
}
