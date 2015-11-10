//
//  Indicis.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Himotoki

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
