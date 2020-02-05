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
