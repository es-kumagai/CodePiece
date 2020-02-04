//
//  TimelineKindState.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/02/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

@objc protocol TimelineKindStateDelegate : class {
	
	@objc optional func timelineKindStateChanged(_ sender: TimelineKindStateController, kind: TimelineKind)
}
