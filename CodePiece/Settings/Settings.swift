//
//  Settings.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

let settings = Settings()

final class Settings {
	
	var account:AccountSetting
	var project:ProjectSetting
	
	private init() {
	
		self.account = AccountSetting()
		self.project = ProjectSetting()
	}
}