//
//  CaptureInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2/28/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import WebKit

// FIXME: ここでのキャプチャーサイズのカスタマイズ機能一式は廃止で良さそう。横幅と最大高さは設定画面で指定できても良さそう。
protocol CaptureInfoType {
	
	var userAgent: String? { get }
	var frameSize: NSSize { get }
	var clientSize: NSSize { get }
	var maxWidth: Int { get }
	var maxHeight: Int { get }
}

struct LinedCaptureInfo : CaptureInfoType {
	
	let userAgent: String? = nil
	let frameSize: NSSize = NSMakeSize(560, 560)
	let clientSize: NSSize = NSMakeSize(680, 40)
	let maxWidth: Int = 380
	let maxHeight: Int = 3000
}
