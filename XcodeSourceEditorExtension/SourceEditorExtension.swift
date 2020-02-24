//
//  SourceEditorExtension.swift
//  XcodeSourceEditorExtension
//
//  Created by Tomohiro Kumagai on 2020/02/21.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
	
	func extensionDidFinishLaunching() {
		// If your extension needs to do any work at launch, implement this optional method.
	}

	// ここでメニューを生成しようとするとなぜか Bad access で落ちてしまうため
	// 今のところは Info.plist でメニューを生成します。
//	var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
//
//		let identifier = Bundle(for: Self.self).bundleIdentifier!
//
//		func command<T: NSObject>(for class: T.Type, name: String) -> Dictionary<XCSourceEditorCommandDefinitionKey, Any> {
//
//			let className = T.className()
//			let classNameWithModule = NSStringFromClass(T.self)
//
//			return [
//				.identifierKey : "\(identifier).\(className)",
//				.classNameKey : classNameWithModule,
//				.nameKey : name
//			]
//		}
//
//		return [
//			command(for: OpenCodePieceCommand.self, name: "Open CodePiece"),
//			command(for: SendToCodePieceCommand.self, name: "Send to CodePiece")
//		]
//	}
}
