//
//  CaptureInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2/28/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import WebKit

// FIXME: ここでのキャプチャーサイズのカスタマイズ機能一式は廃止で良さそう。横幅と最大高さは設定画面で指定できても良さそう。
struct CaptureInfo {
	
	var userAgent: String?
	var minHeight: Int
	var baseHeight: Int
	var extendedHeight: Int
	var aspectWidth: Int
	var aspectHeight: Int
	var clientHeightMargin: Int = 400
	var clientFrameMargin: Int = 100
}

extension CaptureInfo {
	
	func widthFor(height: Int) -> Int {
	
		return height * 16 / 9
	}
	
	var minWidth: Int {
		
		widthFor(height: minHeight)
	}
	
	var maxWidth: Int {

		widthFor(height: baseHeight)
	}
	
	var clientWidth: Int {
	
		widthFor(height: clientHeight)
	}
	
	var clientHeight: Int {
		
		extendedHeight + clientHeightMargin
	}

	var clientFrameWidth: Int {
	
		widthFor(height: clientFrameHeight)
	}
	
	var clientFrameHeight: Int {
		
		clientHeight + clientFrameMargin
	}
}

extension CaptureInfo {

	static let lined = CaptureInfo(userAgent: nil, minHeight: 240, baseHeight: 360, extendedHeight: 1200, aspectWidth: 16, aspectHeight: 9)
}
