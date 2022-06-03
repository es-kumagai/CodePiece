//
//  Task.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/23
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

private extension Task {
	
	final class Result : @unchecked Sendable {

		var state: Swift.Result<Success, Error>!
		
		func succeeded(_ value: Success) {
			
			state = .success(value)
		}
		
		func failed(_ error: Error) {
			
			state = .failure(error)
		}
		
		var value: Success {
			
			get throws {
				try state.get()
			}
		}
	}

	class ResultBox : @unchecked Sendable {
		
		var value: Success?
		
		init(value: Success? = nil) {
			
			self.value = value
		}
	}
}

extension Task where Failure == Never {

	static func blocking(operation: @escaping @Sendable () async -> Success) -> Success {
		
		Semaphore().invokeWithBlocking(operation: operation).value
	}
}

extension Task {

	final class Box : @unchecked Sendable {
		
		var value: Success!
	}
	

	static func blocking(operation: @escaping @Sendable () async throws -> Success) throws -> Success {
		
		try Semaphore().invokeWithThrowingBlocking(operation: operation).get()
	}
}
