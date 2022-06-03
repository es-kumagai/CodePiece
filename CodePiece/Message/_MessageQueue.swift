//
//  MessageQueue_Old.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/04/23
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

#warning("Extension.swift に記載されていたメッセージ処理まわりのコードを移動してきました。ここにある定義は新しいメッセージキューで完全に差し替えられます。不要であることを確実にするため、CodePiece ターゲットから除外してあります。")

import Foundation
import Swim

@available(*, deprecated, message: "Extension.swift に記載されていたメッセージ処理まわりのコードを移動してきました。ここにある定義は新しいメッセージキューで完全に差し替えられます。")
internal enum MessageQueueHandler<Message : MessageType> {

	typealias Queue = MessageQueue<Message>
	typealias MessageHandler = Queue.MessageHandler
	typealias MessageErrorHandler = Queue.MessageErrorHandler?
	
	case Closure(messageHandler: MessageHandler, errorHandler: MessageErrorHandler)
	case Delegate(handler: _MessageQueueHandlerProtocol)
	
	func handlingMessage(message: Message, byQueue queue: Queue) throws {
		
		switch self {
			
		case let .Closure(messageHandler: handler, errorHandler: _):
			try handler(message)
			
		case let .Delegate(handler):
			try handler._messageQueue(queue: queue, handlingMessage: message)
		}
	}
	
	func handlingError(error: Error, byQueue queue: Queue) throws {
		
		switch self {

		case let .Closure(messageHandler: _, errorHandler: handler):
			try handler?(error)
			
		case let .Delegate(handler):
			try handler._messageQueue(queue: queue, handlingError: error)
		}
	}
}

public protocol MessageQueueType : AnyObject {
	
	associatedtype Message : MessageType
}

@available(*, message: "If concurrency is applied to this project, this class may not be necesarry OR needs to imprement as an actor.", renamed: "MessageQueue2")
public actor MessageQueue<M: MessageType> : MessageQueueType {
		
	public static var defaultProcessingInterval: Double {
	
		0.03
	}
	
	public typealias Message = M
	
	@available(*, deprecated, message: "Concurrency に対応したら不要になると思われます。")
	public typealias MessageErrorHandler = (Error) throws -> Void
	@available(*, deprecated, message: "Concurrency に対応したら不要になると思われます。")
	public typealias MessageHandler = (Message) throws -> Void
	@available(*, deprecated, message: "Concurrency に対応したら不要になると思われます。")
	public typealias MessageHandlerNoThrows = (Message) -> Void
	
	private(set) var identifier: String
	
	private var handler: MessageQueueHandler<Message>
	private var messageQueue: Queue<Message>
	
	private var messageProcessingQueue: DispatchQueue
	private var messageHandlerExecutionQueue: DispatchQueue
	private var messageLoopSource: DispatchSourceTimer!
	
	public private(set) var isRunning: Bool

	internal init(identifier: String, executionQueue: DispatchQueue? = nil, processingInterval: Double = MessageQueue.defaultProcessingInterval, handler: MessageQueueHandler<Message>) {
		
		self.identifier = identifier
		self.handler = handler
		
		let queue = DispatchQueue(label: "\(identifier)")
		
		messageProcessingQueue = queue
		messageHandlerExecutionQueue = executionQueue ?? queue
		
		messageQueue = []
		isRunning = false

		messageLoopSource = makeTimerSource(interval: Semaphore.Interval(second: processingInterval), start: true, timerAction: _messageLoopBody)
	}

	public convenience init(identifier:String, executionQueue: DispatchQueue? = nil, processingInterval:Double = MessageQueue.defaultProcessingInterval, messageHandler: @escaping MessageHandler, errorHandler: MessageErrorHandler?) {

		let handler = MessageQueueHandler.Closure(messageHandler: messageHandler, errorHandler: errorHandler)
		
		self.init(identifier: identifier, executionQueue: executionQueue, processingInterval: processingInterval, handler: handler)
	}

	public convenience init(identifier:String, executionQueue: DispatchQueue? = nil, processingInterval:Double = MessageQueue.defaultProcessingInterval, messageHandler: @escaping MessageHandlerNoThrows) {
		
		let handler = MessageQueueHandler.Closure(messageHandler: messageHandler, errorHandler: nil)
		
		self.init(identifier: identifier, executionQueue: executionQueue, processingInterval: processingInterval, handler: handler)
	}
	
	public convenience init<T:_MessageQueueHandlerProtocol>(identifier: String, handler: T, executionQueue: DispatchQueue? = nil, processingInterval: Double = MessageQueue.defaultProcessingInterval) {
		
		let handler = MessageQueueHandler<Message>.Delegate(handler: handler)
		
		self.init(identifier: identifier, executionQueue: executionQueue, processingInterval: processingInterval, handler: handler)
	}
	
	deinit {
		
		messageLoopSource.cancel()
		_stop()
	}

//	public func makeTimerSource(interval: Semaphore.Interval, start: Bool, timerAction: @escaping () -> Void) -> DispatchSourceTimer {
//
//		let source = DispatchSource.makeTimerSource(flags: [], queue: messageProcessingQueue)
//
//
//		return DispatchSource.makeTimerSource(interval: .never, queue: messageProcessingQueue, start: start, eventHandler: timerAction, cancelHandler: nil)
//	}

	public func makeTimerSource(interval: Semaphore.Interval, start: Bool, cancelAction: (() -> Void)? = nil, timerAction: @escaping () -> Void) -> DispatchSourceTimer {

		let source = DispatchSource.makeTimerSource(flags: [], queue: messageProcessingQueue)
		
		source.schedule(deadline: .now(), repeating: interval.second)
		source.setEventHandler(handler: timerAction)
		source.setCancelHandler(handler: cancelAction)
		
		if start {
			
			source.resume()
			isRunning = true
		}
		
		return source
	}
	
	public func start() {
	
		send(.start)
	}
	
	public func stop() {
		
		send(.stop)
	}
	
	private func _start() {
		
		if !isRunning {

			messageLoopSource.resume()
			isRunning = true
		}
	}
	
	private func _stop() {
		
		if isRunning {

			messageLoopSource.suspend()
			isRunning = false
		}
	}
	
	public func send(_ message: MessageQueueControl) {
		
		executeOnProcessingQueue { [unowned self] in

			switch message {
				
			case .start:
				_start()
				
			case .stop:
				_stop()
			}
		}
	}
	
	public func send(message: Message, preAction: @escaping (Queue<Message>, Message) -> Continuous) {
		
		executeOnProcessingQueue { [unowned self] in

			guard preAction(messageQueue, message) == .continue else {
		
				message.messageBlocked()
				return
			}
			
			messageQueue.enqueue(message)
			message.messageQueued()
		}
	}
}

extension MessageQueue where M : MessageType {
	
	public func send(message: Message) {
		
		send(message: message) { (queue, message) -> Continuous in .continue }
	}
	
//	public func sendContinuously(message: Message, interval:Semaphore.Interval) -> DispatchSourceTimer {
//
//		return makeTimerSource(interval: interval, start: true) { [weak self] () -> Void in
//
//			self?.send(message: message)
//		}
//	}
}

extension MessageQueue where M : PreActionMessageType {
	
	public func send(_ message: Message) {
		
		send(message: message) { (queue, message) -> Continuous in
			
			return message.messagePreAction(queue: queue)
		}
	}
	
//	public func sendContinuously(message: Message, interval:Semaphore.Interval) -> DispatchSourceTimer {
//
//		return makeTimerSource(interval: interval, start: true) { [weak self] () -> Void in
//
//			self?.send(message: message)
//		}
//	}
}

/// If you want to manage queue handlers using Cocoa style,
/// let conforms to the protocol, then the instance pass to MessageQueue's initializer.
public protocol _MessageQueueHandlerProtocol {
	
	func _messageQueue<Queue:MessageQueueType>(queue:Queue, handlingMessage:Queue.Message) throws
	func _messageQueue<Queue:MessageQueueType>(queue:Queue, handlingError:Error) throws
}

public protocol MessageQueueHandlerProtocol : _MessageQueueHandlerProtocol {
	
	associatedtype Message : MessageType

	func messageQueue(queue: MessageQueue<Message>, handlingMessage: Message) throws
	func messageQueue(queue: MessageQueue<Message>, handlingError: Error) throws
}

extension MessageQueueHandlerProtocol {
	
	func _messageQueue<Queue>(queue: Queue, handlingMessage message: Queue.Message) throws where Queue: MessageQueueType {

		let queue = queue as! MessageQueue<Message>
		let message = message as! Message
		
		try messageQueue(queue: queue, handlingMessage: message)
	}
	
	func _messageQueue<Queue>(queue: Queue, handlingError error: Error) throws where Queue: MessageQueueType {
		
		let queue = queue as! MessageQueue<Message>
		
		try messageQueue(queue: queue, handlingError: error)
	}
}

extension MessageQueue {

	public func executeSyncOnProcessingQueue<R>(execute: ()->R) -> R {

		messageProcessingQueue.sync(execute: execute)
	}

	public func executeOnProcessingQueue(execute: @escaping () -> ()) {
		
		messageProcessingQueue.async(execute: execute)
	}
	
	public func executeSyncOnHandlerExecutionQueue<R>(execute: ()->R) -> R {
		
		messageHandlerExecutionQueue.sync(execute: execute)
	}
	
	public func executeOnHandlerExecutionQueue(execute: @escaping () -> ()) {
		
		messageHandlerExecutionQueue.async(execute: execute)
	}
	
	func _messageLoopBody() {
	
		guard isRunning else {
			
			return
		}
		
		guard let message = messageQueue.dequeue() else {
			
			return
		}
		
		let handler = self.handler
		
		executeOnHandlerExecutionQueue {

			func executeErrorHandlerIfNeeds(error:Error) {
				
				do {
					
					try handler.handlingError(error: error, byQueue: self)
				}
				catch {
					
					fatalError("An error occurred during executing message handler. \(error)")
				}
			}
			
			do {
				
				try handler.handlingMessage(message: message, byQueue: self)
			}
			catch {

				executeErrorHandlerIfNeeds(error: error)
			}
		}
	}
}
