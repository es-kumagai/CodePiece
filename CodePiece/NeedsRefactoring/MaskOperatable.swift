//
//  MaskOperatable.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/11/27.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

#warning("The implementations in this file don't seems to be used anywhere.")

protocol MaskOperatable {
	
	func masked(reset values: Self...) -> Self
	func masked(reset values: [Self]) -> Self
	func masked(set values: Self...) -> Self
	func masked(set values: [Self]) -> Self
	
	mutating func mask(reset values: Self...)
	mutating func mask(reset values: [Self])
	mutating func mask(set values: Self...)
	mutating func mask(set values: [Self])
}

extension MaskOperatable {
	
	func masked(reset values: Self...) -> Self {
		
		masked(reset: values)
	}
	
	func masked(set values: Self...) -> Self {
		
		masked(set: values)
	}
	
	mutating func mask(reset values: Self...) {
		
		mask(reset: values)
	}
	
	mutating func mask(reset values: [Self]) {
		
		for value in values {
			
			self = masked(reset: value)
		}
	}
	
	mutating func mask(set values: Self...) {
		
		mask(set: values)
	}
	
	mutating func mask(set values: [Self]) {
		
		for value in values {
			
			self = masked(set: value)
		}
	}
}

extension Int : MaskOperatable {
	
	func masked(reset values: [Int]) -> Int {
		
		values.reduce(self) { $0 & ~$1 }
	}
	
	func masked(set values: [Int]) -> Int {
		
		values.reduce(self) { $0 | $1 }
	}
}
