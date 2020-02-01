//
//  StatusImageView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/16.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
@IBDesignable final class StatusImageView: NSImageView {

	private let StatusCodingKey = "StatusImageViewStatusCoding"
	private let StatusDefault = Status.none
	
	@objc public enum Status : Int {

		case none
		case available
		case partiallyAvailable
		case unavailable
		
		var image: NSImage {
			
			return NSImage(self)
		}
	}
	
	public override init(frame frameRect: NSRect) {
		
		self.status = StatusDefault
		super.init(frame: frameRect)

		self.updateStatusImage()
	}
	
	public required init?(coder: NSCoder) {

		if coder.containsValue(forKey: StatusCodingKey), let status = Status(rawValue: coder.decodeInteger(forKey: StatusCodingKey)) {
			
			self.status = status
		}
		else {
			
			self.status = self.StatusDefault
		}

		super.init(coder: coder)

		self.updateStatusImage()
	}
	
	public override func encode(with aCoder: NSCoder) {
		
		super.encode(with: aCoder)
		
		aCoder.encode(status.rawValue, forKey: StatusCodingKey)
	}
	
	@IBInspectable public var status: Status {
	
		didSet {

			self.updateStatusImage()
		}
	}
	
	private func updateStatusImage() {
		
		self.image = self.status.image
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
