//
//  Alert.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

protocol AlertDisplayable {

}

extension NSViewController : AlertDisplayable {
	
}

@MainActor
extension AlertDisplayable {

	@discardableResult
	func showInformationAlert(withTitle title: String, message: String) -> NSApplication.ModalResponse {
		
		Self.showInformationAlert(withTitle: title, message: message)
	}
	
	@discardableResult
	func showWarningAlert(withTitle title: String, message: String, debugDescription: String? = nil) -> NSApplication.ModalResponse {
		
		Self.showWarningAlert(withTitle: title, message: message, debugDescription: debugDescription)
	}
	
	@discardableResult
	func showErrorAlert(withTitle title: String, message: String, debugDescription: String? = nil) -> NSApplication.ModalResponse {
		
		Self.showErrorAlert(withTitle: title, message: message, debugDescription: debugDescription)
	}
	
	@discardableResult
	private static func showAlert(_ alert: NSAlert) -> NSApplication.ModalResponse {

		alert.runModal()
	}
	
	@discardableResult
	static func showInformationAlert(withTitle title: String, message: String) -> NSApplication.ModalResponse {
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButton(withTitle: "OK")
		alert.alertStyle = .informational
		
		return showAlert(alert)
	}
	
	@discardableResult
	static func showWarningAlert(withTitle title: String, message: String, debugDescription: String? = nil) -> NSApplication.ModalResponse {
		
		NSLog("Warning: \(title) : \(message)\(debugDescription.map { " \($0)" } ?? "")")
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButton(withTitle: "OK")
		alert.alertStyle = .warning
		
		return showAlert(alert)
	}
	
	@discardableResult
	static func showErrorAlert(withTitle title: String, message: String, debugDescription: String? = nil) -> NSApplication.ModalResponse {

		NSLog("Error: \(title) : \(message)\(debugDescription.map { " \($0)" } ?? "")")
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButton(withTitle: "OK")
		alert.alertStyle = .critical

		return showAlert(alert)
	}
}
