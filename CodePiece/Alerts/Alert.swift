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

extension AlertDisplayable {

	func showInformationAlert(withTitle title: String, message: String) {
		
		Self.showInformationAlert(withTitle: title, message: message)
	}
	
	func showWarningAlert(withTitle title: String, message: String, debugDescription: String? = nil) {
		
		Self.showWarningAlert(withTitle: title, message: message, debugDescription: debugDescription)
	}
	
	func showErrorAlert(withTitle title: String, message: String, debugDescription: String? = nil) {
		
		Self.showErrorAlert(withTitle: title, message: message, debugDescription: debugDescription)
	}
	
	private static func showAlert(_ alert: NSAlert) {
	
		DispatchQueue.main.async {
			
			alert.runModal()
		}
	}
	
	static func showInformationAlert(withTitle title: String, message: String) {
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButton(withTitle: "OK")
		alert.alertStyle = .informational
	
		showAlert(alert)
	}
	
	static func showWarningAlert(withTitle title: String, message: String, debugDescription: String? = nil) {
		
		NSLog("Warning: \(title) : \(message)\(debugDescription.map { " \($0)" } ?? "")")
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButton(withTitle: "OK")
		alert.alertStyle = .warning
		
		self.showAlert(alert)
	}
	
	static func showErrorAlert(withTitle title: String, message: String, debugDescription: String? = nil) {

		NSLog("Error: \(title) : \(message)\(debugDescription.map { " \($0)" } ?? "")")
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButton(withTitle: "OK")
		alert.alertStyle = .critical

		self.showAlert(alert)
	}
}
