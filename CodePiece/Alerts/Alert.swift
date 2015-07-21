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

	func showInformationAlert(title:String, message:String) {
		
		self.dynamicType.showInformationAlert(title, message: message)
	}
	
	func showWarningAlert(title:String, message:String) {
		
		self.dynamicType.showWarningAlert(title, message: message)
	}
	
	func showErrorAlert(title:String, message:String) {
		
		self.dynamicType.showErrorAlert(title, message: message)
	}
	
	static func showInformationAlert(title:String, message:String) {
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButtonWithTitle("OK")
		alert.alertStyle = .InformationalAlertStyle
		
		alert.runModal()
	}
	
	static func showWarningAlert(title:String, message:String) {
		
		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButtonWithTitle("OK")
		alert.alertStyle = .WarningAlertStyle
		
		alert.runModal()
	}
	
	static func showErrorAlert(title:String, message:String) {

		let alert = NSAlert()
		
		alert.messageText = title
		alert.informativeText = message
		alert.addButtonWithTitle("I see")
		alert.alertStyle = .CriticalAlertStyle

		alert.runModal()
	}
}
