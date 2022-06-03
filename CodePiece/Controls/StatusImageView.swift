//
//  StatusImageView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/16.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@MainActor
@objcMembers
@IBDesignable final class StatusImageView: NSImageView {

	private let statusCodingKey = "StatusImageViewStatusCoding"
	private let statusDefault = Status.none
	
	public override init(frame frameRect: NSRect) {
		
		status = statusDefault
		super.init(frame: frameRect)

		updateStatusImage()
	}
	
	public required init?(coder: NSCoder) {

		if coder.containsValue(forKey: statusCodingKey), let status = Status(rawValue: coder.decodeInteger(forKey: statusCodingKey)) {
			
			self.status = status
		}
		else {
			
			self.status = statusDefault
		}

		super.init(coder: coder)

		updateStatusImage()
	}
	
	public override func encode(with aCoder: NSCoder) {
		
		super.encode(with: aCoder)
		
		aCoder.encode(status.rawValue, forKey: statusCodingKey)
	}
	
	@IBInspectable public var status: Status {
	
		didSet {

			updateStatusImage()
		}
	}
	
	private func updateStatusImage() {
		
		image = status.image
	}
}

extension NSImage {
	
	convenience init(_ status: StatusImageView.Status) {
		
		switch status {
			
		case .none:
			self.init(named: "NSStatusNone")!
			
		case .available:
			self.init(named: "NSStatusAvailable")!

		case .partiallyAvailable:
			self.init(named: "NSStatusPartiallyAvailable")!

		case .unavailable:
			self.init(named: "NSStatusUnavailable")!
		}
	}
}
