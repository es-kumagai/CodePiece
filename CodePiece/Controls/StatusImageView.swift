//
//  StatusImageView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/08/16.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@IBDesignable public class StatusImageView: NSImageView {

	private let StatusCodingKey = "StatusImageViewStatusCoding"
	private let StatusDefault = Status.None
	
	@objc public enum Status : Int {

		case None
		case Available
		case PartiallyAvailable
		case Unavailable
		
		var image:NSImage {
			
			return NSImage(named: "NSStatus\(self)")!
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
