//
//  CaptureInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2/28/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import WebKit

/// Detail information for gist capture.
///
/// This instance specify a user agent and the frame size.
/// Widths are set automatically to set heights.
struct CaptureInfo {
	
	/// The identifier for specify a user agent.
	/// If this property assign nil, a default user agent will be used.
	var userAgent: String?
	
	/// The minimum height when taking a capture image.
	var minHeight: Int
	
	/// The base height when taking a capture image.
	/// This value is used to determine the maximum width of capture image.
	var baseHeight: Int
	
	/// The maximum height when taking a capture image.
	var extendedHeight: Int
	
	/// The aspect width for calculating a appropriate size of the capture image.
	var aspectWidth: Int
	
	/// The aspect height for calculating a appropriate size of the capture image.
	var aspectHeight: Int
	
	/// The mergin of the user agent client height to take extra height than the capture size.
	var clientHeightMargin: Int = 400

	/// The mergin for the user agent client frame height to take extra height than the client size for taking the capture.
	var clientFrameMargin: Int = 100
}

extension CaptureInfo {
	
	/// Calculate the width for a height by taking aspect ratio.
	/// - Parameter height: the height to calculate a width.
	/// - Returns: The width calculated from passed height.
	func widthFor(height: Int) -> Int {
	
		return height * 16 / 9
	}
	
	/// The minimum height when taking a capture image.
	/// This value is calclated from `minHeight`.
	var minWidth: Int {
		
		widthFor(height: minHeight)
	}
	
	/// The maximum height when taking a capture image.
	/// This value is calclated from `baseHeight`.
	var maxWidth: Int {

		widthFor(height: baseHeight)
	}
	
	/// The width of the screen width for taking the capture image.
	var clientWidth: Int {
	
		widthFor(height: clientHeight)
	}
	
	/// The height of the screen width for taking the capture image.
	var clientHeight: Int {
		
		extendedHeight + clientHeightMargin
	}

	/// The width of the frame of the user agent.
	var clientFrameWidth: Int {
	
		widthFor(height: clientFrameHeight)
	}
	
	/// The height of the frame of the user agent.
	var clientFrameHeight: Int {
		
		clientHeight + clientFrameMargin
	}
}

extension CaptureInfo {
	
	/// A capture information that is appropriate for twitter.
	static let twitterGeneric = CaptureInfo(userAgent: nil, minHeight: 240, baseHeight: 360, extendedHeight: 1200, aspectWidth: 16, aspectHeight: 9)
}
