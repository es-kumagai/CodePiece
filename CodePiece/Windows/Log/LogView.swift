//
//  LogView.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/09/28
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import SwiftUI

struct LogView : View {
	
	@MainActor
	@StateObject var log: Log = .standard
	
	@State var size: NSSize
	
	init(size: NSSize) {

		self.size = size
	}
	
	init(size: NSSize, log: Log) {
		
		self.init(size: size)
		self.log.append(log: log)
	}

	var body: some View {
		
		ScrollViewReader { reader in
			ScrollView {
				VStack(alignment: .leading, spacing: 3) {
					ForEach(log.items, content: \.view)
				}
			}
			.padding()
			.onAppear {
				if let id = log.lastId {
					withAnimation {
						reader.scrollTo(id)
					}
				}
			}
		}
		.frame(minWidth: size.width, minHeight: size.height)
	}
}

struct ContentView_Previews : PreviewProvider {
	static var previews: some View {
		
		let log = Log(items: [
			LogItem.information("最初のテストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.warning("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.debug("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.error("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.debug("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.warning("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.debug("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.error("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.debug("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.warning("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.debug("テストメッセージ"),
			LogItem.error("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.debug("テストメッセージ"),
			LogItem.warning("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.debug("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.error("テストメッセージ"),
			LogItem.information("テストメッセージ"),
			LogItem.information("最後のテストメッセージ"),
		])
		
		LogView(size: NSSize(width: 100, height: 200), log: log)
	}
}
