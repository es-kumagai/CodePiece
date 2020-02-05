//
//  TimelineMessageQueue.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/28.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Cocoa

// FIXME: TimelineViewController の更新処理の Swift 5 への移行で動作しなくなり、複雑な印象なので書き直そうと思いましたが、いったん保留で元のを完成させます。

final class TimelineMessageQueue {
	
	private var queue: DispatchQueue
	
	init() {
		
		queue = DispatchQueue(label: "jp.ez-net.codepiece.messageloop.timeline")
	}
}
