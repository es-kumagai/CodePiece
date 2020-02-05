//
//  TimelineTabViewItemInformation.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/05.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit

extension TimelineKindStateController {
	
	struct TabInformation {

		var kind: TimelineKind
		var button: NSButton
		var state: TimelineState
		var controller: TimelineContentsController
		var autoUpdateInterval: Double? = nil
		
		/// Tab item order.
		///
		/// Now the value is not effectively. If tab buttons become to generate
		/// automatically by code, this value used to ordering tabs.
		var tabOrder: Int
	}
}

extension TimelineKindStateController.TabInformation : Hashable, Identifiable {
	
	var id: TimelineKind {

		return kind
	}
}

extension Collection where Element == TimelineKindStateController.TabInformation {
	
	subscript(kind: TimelineKind) -> Element? {
		
		return first { $0.kind == kind }
	}
}
