//
//  Indicis.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

public protocol HasIndices {

	var indices: Indices { get }
}

extension CollectionType where Generator.Element : HasIndices {
	
	public var sortedByIndicesAscend: Array<Generator.Element> {
	
		return sort {
			
			let (lhs, rhs) = ($0.indices, $1.indices)
			
			if lhs.startIndex == rhs.startIndex {
				
				return lhs.endIndex < rhs.endIndex
			}
			else {
				
				return lhs.startIndex < rhs.startIndex
			}
		}
	}
	
	public var sortedByIndicesDescend: Array<Generator.Element> {
		
		return sort {
			
			let (lhs, rhs) = ($0.indices, $1.indices)
			
			if lhs.endIndex == rhs.endIndex {
				
				return lhs.startIndex > rhs.startIndex
			}
			else {
				
				return lhs.endIndex > rhs.endIndex
			}
		}
	}
}

public struct Indices {
	
	public var startIndex:Int
	public var endIndex:Int
	
	public enum InitializeError : ErrorType {
		
		case InvalidArgument(String)
	}
}

extension Indices.InitializeError : CustomStringConvertible {
	
	public var description: String {
		
		switch self {
			
		case let .InvalidArgument(argument):
			return "Indices Initialize Error : Invalid Argument (\(argument))"
		}
	}
}


extension Indices {

	internal init(twitterIndicesArray array:Array<Int>) throws {
	
		guard array.count == 2 else {
			
			throw InitializeError.InvalidArgument("\(array)")
		}
		
		guard case let (start, end) = (array[0], array[1]) where start <= end else {
			
			throw InitializeError.InvalidArgument("\(array)")
		}

		self.init(startIndex: start, endIndex: end)
	}
}

extension Indices : Decodable {

	public static func decode(e: Extractor) throws -> Indices {

		do {

			return try Indices(twitterIndicesArray: decodeArray(e.rawValue))
		}
		catch InitializeError.InvalidArgument(let value) {
			
			throw DecodeError.TypeMismatch(expected: "\(Indices.self)", actual: "\(value)", keyPath: "indices")
		}
	}
}

extension NSRange {
	
	public init(_ indices: Indices) {
		
		self.init(indices.startIndex ..< indices.endIndex)
	}
	
	public init(_ indices: Indices, offset: Int) {
		
		self.init(indices.startIndex.advancedBy(offset) ..< indices.endIndex.advancedBy(offset))
	}
}
