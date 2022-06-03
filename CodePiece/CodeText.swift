//
//  CodeText.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 1/19/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import Foundation
import CodePieceCore

@MainActor
protocol CodeTextType {
	
	var code: Code { get }
	
	mutating func clearCodeText()
}

extension CodeTextType {

	var hasCode: Bool {
		
		!code.isEmpty
	}
}
