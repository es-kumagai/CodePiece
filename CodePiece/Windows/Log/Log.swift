//
//  Log.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/09/28
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import SwiftUI

@MainActor
@dynamicMemberLookup
class Log : ObservableObject {
	
	typealias KindPath = KeyPath<LogItem.Kind, LogItemKind>
	
	@Published var items: LogItems
	
	init(items: LogItems = []) {
		self.items = items
	}
	
	nonisolated
	static subscript(dynamicMember kind: KindPath) -> (String) -> Void {
		
		{ message in
			
			let kind = LogItem.Kind.shared[keyPath: kind]
			let item = LogItem(kind: kind, message: message)
			
			send(item)
		}
	}
	
}

extension Log {
	
	static let standard = Log()
	
	var lastId: String? {
		
		items.last?.id
	}
	
	func send(_ item: LogItem) {
		
		items.append(item)
	}
	
	func append(log: Log) {
		
		items.append(contentsOf: log.items)
	}
	
	func clear() {
		
		items.removeAll()
	}
	
	nonisolated static func send(_ item: LogItem) {
		
		NSLog("%@", item.description)
		
		Task.detached {
			await standard.send(item)
		}
	}
	
	nonisolated static func clear() {
		
		Task.detached {
			
			await standard.clear()
		}
	}
}
