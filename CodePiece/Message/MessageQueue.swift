//
//  MessageQueue.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/23
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

@preconcurrency import Swim
import Dispatch
import Foundation

public let messageQueueDefaultProcessingInterval = Semaphore.Interval(second: 0.03)

public actor MessageQueue<Message : MessageType> {
	
	public typealias Messages = Queue<Message>
	public typealias PreAction = @Sendable (_ queue: MessageQueue, _ message: Message) async -> Continuous
	public typealias MessageHandler = @Sendable (_ queue: MessageQueue, _ message: Message) async throws -> Void
	public typealias ErrorHandler = @Sendable (_ queue: MessageQueue, _ error: Error) async throws -> Void

	public var messageHandler: MessageHandler?
	public var errorHandler: ErrorHandler?
	
	public private(set) var messages: Messages
	private var messageLoopSource: DispatchSourceTimer
	private var messageLoopInterval: Semaphore.Interval
	
	public let identifier: String
	public private(set) var isRunning: Bool = false
	
	public init(identifier: String, messageLoopInterval: Semaphore.Interval = messageQueueDefaultProcessingInterval, messageHandler: MessageHandler? = nil, errorHandler: ErrorHandler? = nil) {

		self.identifier = identifier
		self.messages = []
		self.messageHandler = messageHandler
		self.errorHandler = errorHandler
		
		self.messageLoopSource = DispatchSource.makeTimerSource(flags: [], queue: nil)
		self.messageLoopInterval = messageLoopInterval
	}
	
	deinit {
	
		messageLoopSource.cancel()
		stop()
	}
	
	public func prepare() {
		
		messageLoopSource.schedule(deadline: .now(), repeating: messageLoopInterval.second)
		messageLoopSource.setEventHandler(handler: messageLoop)
		messageLoopSource.setCancelHandler(handler: messageLoopCancelation)
		
		start()
	}
	
	public nonisolated func send(_ message: MessageQueueControl) {
		
		Task {

			switch message {

			case .start:
				await start()
				
			case .stop:
				await stop()
			}
		}
	}

	public nonisolated func send(_ message: Message, preAction: PreAction?) {
		
		Task {

			switch await preAction?(self, message) {
				
			case .continue?, nil:
				await enqueue(message)

			case .abort:
				message.messageBlocked()
			}
		}
	}
}

internal extension MessageQueue {
	
	func start() {
		
		if !isRunning {
			
			messageLoopSource.resume()
			isRunning = true
		}
	}
	
	func stop() {
		
		if isRunning {
			
			messageLoopSource.suspend()
			isRunning = false
		}
	}
	
	func enqueue(_ message: Message) {
		
		messages.enqueue(message)
		message.messageQueued()
	}
}

private extension MessageQueue {
	
	func messageLoop() {
		
		guard isRunning else {
			
			return
		}
		
		guard let message = messages.dequeue() else {
			
			return
		}
		
		Task {

			do {
				try await messageHandler?(self, message)
			}
			catch {
				
				do {
					guard let errorHandler = errorHandler else {
						
						throw error
					}

					try await errorHandler(self, error)
				}
				catch {
					
					NSLog("An error occurred during executing message handler: \(error)")
				}
			}
		}
	}
	
	func messageLoopCancelation() {
		
		Task {
			
			do {
				try await messageLoopBody()
			}
			catch {
				
				NSLog("An error occurred during executing message handler: \(error)")
			}
		}
	}

	func messageLoopBody() async throws {
		
		guard isRunning else {
			
			return
		}
		
		guard let message = messages.dequeue() else {
			
			return
		}
		
		do {
			try await messageHandler?(self, message)
		}
		catch {
			
			guard let errorHandler = errorHandler else {
				
				throw error
			}
			
			try await errorHandler(self, error)
		}
	}
}

extension MessageQueue where Message : PreActionMessageType {
	
	public nonisolated func send(_ message: Message) {
		
		send(message) { (queue, message) -> Continuous in
			
			await message.messagePreAction(queue: queue.messages)
		}
	}
}
