//
//  LogItem.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/09/28
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import SwiftUI

@dynamicMemberLookup
struct LogItem : Sendable, Identifiable {
	
	let id = UUID().uuidString
	let date = Date()
	
	var kind: LogItemKind
	var message: String
	
	init(kind: LogItemKind, message: String) {
		
		self.kind = kind
		self.message = message
	}
}

typealias LogItems = [LogItem]

extension LogItem : CustomStringConvertible {

	static subscript(dynamicMember kind: Log.KindPath) -> (String) -> LogItem {
	
		let kind = Kind.shared[keyPath: kind]
		
		return { message in
			
			LogItem(kind: kind, message: message)
		}
	}
	
	var description: String {
		
		if let prefix = kind.symbolText {
			
			return "\(prefix) \(message)"
		}
		else {
			
			return message
		}
	}
	
	@ViewBuilder @MainActor
	var view: some View {

		HStack(alignment: .top, spacing: 8) {
			
			Text(date.description)
			kind.symbolView
			Text(message).foregroundColor(kind.symbolColor)
		}
		
	}
}

