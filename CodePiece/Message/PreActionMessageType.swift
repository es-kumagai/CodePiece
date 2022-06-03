//
//  PreActionMessageType.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/23
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import Swim

public protocol PreActionMessageType : MessageType {
	
	func messagePreAction(queue: Queue<Self>) -> Continuous
}
