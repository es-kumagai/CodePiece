//
//  LogItemKind.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/09/28
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

@preconcurrency import SwiftUI

protocol LogItemKind : Sendable {
	
	var symbolText: String? { get }
	var symbolColor: Color { get }
	
	@ViewBuilder @MainActor
	var symbolView: LogItem.Kind.SymbolView { get }
}

extension LogItemKind {
	
	@ViewBuilder @MainActor var symbolView: LogItem.Kind.SymbolView {
		
		LogItem.Kind.SymbolView(item: self)
	}
}

extension LogItem {
	
	struct Kind {
		
		private init() {}
		
		internal static let shared = Kind()
	}
}

extension LogItem.Kind {

	@inlinable var information: LogItemKind { Information() }

	struct Information : LogItemKind {
		
		let symbolText: String? = nil
		let symbolColor: Color = .textColor
	}
	
	@inlinable var trying: LogItemKind { Trying() }
	
	struct Trying : LogItemKind {

		let symbolText: String? = nil
		let symbolColor: Color = .tryingColor
	}
	
	@inlinable var success: LogItemKind { Success() }
	
	struct Success : LogItemKind {
		
		let symbolText: String? = nil
		let symbolColor: Color = .successColor
	}
	
	@inlinable var warning: LogItemKind { Warning() }
	
	struct Warning : LogItemKind {
		
		let symbolText: String? = "WARNING"
		let symbolColor: Color = .warningColor
	}
	
	@inlinable var error: LogItemKind { Error() }
	
	struct Error : LogItemKind {
		
		let symbolText: String? = "ERROR"
		let symbolColor: Color = .errorColor
	}
	
	@inlinable var debug: LogItemKind { Debug() }
	
	struct Debug : LogItemKind {

		let symbolText: String? = "DEBUG"
		let symbolColor: Color = .debugTextColor
	}
}
