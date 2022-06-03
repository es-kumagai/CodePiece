//
//  DebugTime.swift
//  CodePieceCore
//
//  Created by kumagai on 2020/05/26.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

public final class DebugTime {

	public static func print(_ message: @autoclosure () -> String) {

		#if DEBUG
		NSLog("%@", message())
		#endif
	}

	public static func printAsync(_ message: @autoclosure () async -> String) async {

		#if DEBUG
		let messageQueue = await message()
		print(messageQueue)
		#endif
	}
}
