//
//  Indicis.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public protocol HasIndices {

	var indices: Indices { get }
}

extension Collection where Element : HasIndices {
	
	public var sortedByIndicesAscend: Array<Element> {
	
		return sorted {
			
			let (lhs, rhs) = ($0.indices, $1.indices)
			
			switch lhs.startIndex == rhs.startIndex {
				
			case true:
				return lhs.endIndex < rhs.endIndex

			case false:
				return lhs.startIndex < rhs.startIndex
			}
		}
	}
	
	public var sortedByIndicesDescend: Array<Element> {
		
		return sorted {
			
			let (lhs, rhs) = ($0.indices, $1.indices)
			
			switch lhs.endIndex == rhs.endIndex {
				
			case true:
				return lhs.startIndex > rhs.startIndex

			case false:
				return lhs.endIndex > rhs.endIndex
			}
		}
	}
}

public struct Indices : Sendable {
	
	public var startIndex: Int
	public var endIndex: Int
	
	public enum InitializeError : Error {
		
		case InvalidArgument(String)
	}
}

extension Indices.InitializeError : CustomStringConvertible {
	
	public var description: String {
		
		switch self {
			
		case let .InvalidArgument(argument):
			return "Indices Initialization Error : Invalid Argument (\(argument))"
		}
	}
}


extension Indices {

	internal init(twitterIndicesArray array:Array<Int>) throws {
	
		guard array.count == 2 else {
			
			throw InitializeError.InvalidArgument("\(array)")
		}
		
		guard case let (start, end) = (array[0], array[1]), start <= end else {
			
			throw InitializeError.InvalidArgument("\(array)")
		}

		self.init(startIndex: start, endIndex: end)
	}
}

extension Indices : Decodable {

	public init(from decoder: Decoder) throws {
	
		let container = try decoder.singleValueContainer()
		let indicesArray = try container.decode([Int].self)
		
		do {
			
			try self.init(twitterIndicesArray: indicesArray)
		}
		catch {
			
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid indices format.")
		}
	}
}

extension Indices {
	
	public func added(offset: Int) -> Indices {
		
		return Indices(startIndex: startIndex + offset, endIndex: endIndex + offset)
	}
}

extension NSRange {
	
	public init(_ indices: Indices) {
		
		self.init(indices.startIndex ..< indices.endIndex)
	}
	
	public init(_ indices: Indices, offset: Int) {
		
		self.init(indices.startIndex + offset ..< indices.endIndex + offset)
	}
}
