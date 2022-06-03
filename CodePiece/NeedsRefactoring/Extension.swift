//
//  Extension.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

// 将来的に別のモジュールへ移動できそうな機能を実装しています。

import APIKit
import AppKit
import Ocean
import Swim
import Sky
import Dispatch
import OAuth2

public var OutputStream = StandardOutputStream()
public var ErrorStream = StandardErrorStream()
public var NullStream = NullOutputStream()

extension NotificationObservable {
	
	public func observe<T: NotificationProtocol & Sendable>(_ notification: T.Type, object: Any? = nil, queue: OperationQueue? = nil, using handler: @escaping @Sendable @MainActor (T) async -> Void) {
		
		notificationHandlers.observe(notification, object: object, queue: queue) { notification in
			
			Task { @MainActor in
				
				await handler(notification)
			}
		}
	}
}

extension OAuth2 {
	
	func authorize(params: OAuth2StringDict? = nil) async throws -> OAuth2JSON {
		
		try await withCheckedThrowingContinuation { continuation in
			
			authorize(params: params) { json, error in

				switch (json, error) {
					
				case (let json?, nil):
					continuation.resume(returning: json)

				case (_, let error?):
					continuation.resume(throwing: error)
					
				case (nil, nil):
					fatalError("Unexpected error in OAuth2.authorize(params:).")
				}
			}
		}
	}
}

// NOTE: 🐬 CodePiece の Data を扱うときに HTMLText を介すると attributedText の実装が逆に複雑化する可能性があるため、一旦保留にします。
//public struct HTMLText {
//
//	public var source: String
//	public var encoding: NSStringEncoding
//	
//	public init(source: String, encoding: NSStringEncoding = NSUTF8StringEncoding) {
//		
//		self.source = source
//		self.encoding = encoding
//	}
//
//	public var html: NSData {
//		
//		return source.dataUsingEncoding(NSUTF16StringEncoding, allowLossyConversion: true)!
//	}
//	
//	public var attributedText: NSAttributedString {
//		
////		let options: [String:AnyObject] = [NSFontAttributeName:NSFont(name: "SourceHanCodeJP-Regular", size: 13.0)!]
//		
////		return NSAttributedString(string: source)
//		return NSAttributedString(HTML: html, options: [:], documentAttributes: nil)!
//	}
//}
//
//extension HTMLText : StringLiteralConvertible {
//
//	public init(stringLiteral value: String) {
//
//		self.init(source: value)
//	}
//
//	public init(extendedGraphemeClusterLiteral value: String) {
//		
//		self.init(source: value)
//	}
//	
//	public init(unicodeScalarLiteral value: String) {
//
//		self.init(source: value)
//	}
//}
//
//extension HTMLText : RawRepresentable {
//	
//	public init(rawValue: String) {
//		
//		self.init(source: rawValue, encoding: NSUTF8StringEncoding)
//	}
//	
//	public var rawValue: String {
//		
//		return source
//	}
//}

//extension DateComponents {
//
//	public convenience init<S: Sequence>(sequence s: S) where S.Element == Int {
//
//        let indexes = s.reduce(NSMutableIndexSet()) { $0.add($1); return $0 }
//
//		self.init(indexSet: (indexes.copy() as! DateComponents) as IndexSet)
//	}
//}
//
//extension DateComponents {
//
//	public var isEmpty: Bool {
//
//		return count == 0
//	}
//}

extension NSTableView {

	func topObjectsInRegisteredNibByIdentifier(identifier: NSUserInterfaceItemIdentifier) -> [AnyObject]? {
		
		guard let nib = registeredNibsByIdentifier![identifier] else {
			
			return nil
		}
		
		var topObjects = NSArray() as Optional
		
		guard nib.instantiate(withOwner: nil, topLevelObjects: &topObjects) else {
			
			fatalError("Failed to load nib '\(nib)'.")
		}
		
		return topObjects as [AnyObject]?
	}
}

public func bundle<First,Second>(first: First) -> (Second) -> (First, Second) {

	{ second in (first, second) }
}

public func bundle<First,Second>(first: First, second: Second) -> (First, Second) {
	
	(first, second)
}

func mask(mask:Int, reset values:Int...) -> Int {
	
	values.reduce(mask) { $0 & ~$1 }
}

func mask( mask: inout Int, reset values: Int...) {
	
	values.forEach { mask = mask & ~$0 }
}

public protocol UnsignedIntegerConvertible {

	func toUInt() -> UInt
}

//extension UIntMax {
//
//	public init<T:UIntMaxConvertible>(_ value:T) {
//
//		self = value.toUIntMax()
//	}
//}
//
//extension Semaphore.Interval : UIntMaxConvertible {
//
//	public init(_ value:UIntMax) {
//
//		self.init(rawValue: value.toIntMax())
//	}
//
//	public func toUIntMax() -> UIntMax {
//
//		return self.rawValue.toUIntMax()
//	}
//}

public final class Dispatch {

	public static func makeTimer(interval: DispatchTimeInterval, queue: DispatchQueue? = nil, start: Bool, timerAction: @escaping () -> Void) -> DispatchSourceTimer {
		
		makeTimer(interval: interval, queue: queue, start: start, timerAction: timerAction, cancelHandler: nil)
	}
	
	public static func makeTimer(interval: DispatchTimeInterval, queue: DispatchQueue? = nil, start: Bool, timerAction: @escaping () -> Void, cancelHandler: (() -> Void)?) -> DispatchSourceTimer {

		let source = DispatchSource.makeTimerSource(flags: [], queue: queue)

		source.setEventHandler(handler: timerAction)
		
		if let cancelHandler = cancelHandler {
			
			source.setCancelHandler(handler: cancelHandler)
		}
		
		source.schedule(deadline: .now(), repeating: interval)
		
		if start {
			
			source.resume()
		}
		
		return source
	}
}

extension DispatchSource {
	
	public func setTimer(interval: UInt64, start: DispatchTime = .now(), leeway: UInt64 = 0) {
		
		return __dispatch_source_set_timer(self, start.rawValue, interval, leeway)
	}
}

public struct Repeater<Element> : Sequence {

	private var generator: RepeaterGenerator<Element>
	
	public init(_ value:Element) {
		
		self.init { value }
	}
	
	public init (_ generate: @escaping () -> Element) {
		
		generator = RepeaterGenerator(generate)
	}
	
	public func makeIterator() -> RepeaterGenerator<Element> {
		
		generator
	}
	
	public func zipLeftOf<S:Sequence>(s:S) -> Zip2Sequence<Repeater,S> {
		
		zip(self, s)
	}
	
	public func zipRightOf<S:Sequence>(s:S) -> Zip2Sequence<S,Repeater> {
		
		zip(s, self)
	}
}

public struct RepeaterGenerator<Element> : IteratorProtocol {
	
	private var _generate:()->Element
	
	init(_ value:Element) {
		
		self.init { value }
	}
	
    init (_ generate: @escaping ()->Element) {
		
		_generate = generate
	}
	
	public func next() -> Element? {
		
		_generate()
	}
}


@MainActor
public protocol Selectable : AnyObject {
	
	var selected: Bool { get set }
}

extension Selectable {
	
	public static func selected(instance: Self) -> () -> Bool {
		
		{ instance.selected }
	}
	
	public static func setSelected(instance: Self) -> (Bool) -> Void {
		
		{ instance.selected = $0 }
	}
}

extension Sequence where Element : Selectable {

	@MainActor
	public mutating func selectAll() {
		
		forEach { $0.selected = true }
	}
	
	@MainActor
	public mutating func deselectAll() {
		
		forEach { $0.selected = false }
	}
}

extension Sequence where Element : AnyObject {
	
	public var selectableElementsOnly: [Selectable] {
		
		compactMap { $0 as? Selectable }
	}
}


extension Optional {

	public func ifHasValue(predicate:(Wrapped) throws -> Void) rethrows {
		
		if case let value? = self {
			
			try predicate(value)
		}
	}
}

extension Bool {

	public func isTrue(predicate:() throws -> Void) rethrows {
		
		if self {
			
			try predicate()
		}
	}
	
	public func isFalse(predicate:() throws -> Void) rethrows {
		
		if !self {
			
			try predicate()
		}
	}
}

public class StandardOutputStream : OutputStream {
	
	public func write(string: String) {
		
		print(string)
	}
}

public class StandardErrorStream : OutputStream {
	
	public func write(string: String) {
		
		debugPrint(string)
	}
}

public class NullOutputStream : OutputStream {
	
	public func write(string: String) {
		
	}
}

extension Optional {
	
	public func executeIfExists(_ expression: (Wrapped) throws -> Void) rethrows -> Void {
		
		if let value = self {

			try expression(value)
		}
	}
}

/// Execute `exression`. If an error occurred, write the error to standard output stream.
public func handleError(expression: @autoclosure () throws -> Void) rethrows -> Void {
	
    try handleError(expression: expression(), to: &OutputStream)
}

/// Execute `exression`. If an error occurred, write the error to standard output stream.
public func handleError<R>(expression: @autoclosure () throws -> R) rethrows -> R? {

    return try handleError(expression: expression(), to: &OutputStream)
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<STREAM: OutputStream>(expression: @autoclosure () throws -> Void, to stream: inout STREAM) rethrows -> Void {
	
	try handleError(expression: expression()) { (error:Error)->Void in
		
        stream.write("Error Handling: \(error)", maxLength: Int.max)
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R,STREAM: OutputStream>(expression: @autoclosure () throws -> R, to stream: inout STREAM) rethrows -> R? {
	
	try handleError(expression: expression()) { (error: Error)->Void in
		
		stream.write("Error Handling: \(error)", maxLength: Int.max)
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError(expression: @autoclosure () throws -> Void, by handler:(Error)->Void) -> Void {
	
	do {
		
		try expression()
	}
	catch {
		
		handler(error)
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R>(expression: @autoclosure () throws -> R, by handler:(Error)->Void) -> R? {
	
	do {
		
		return try expression()
	}
	catch {
		
		handler(error)
		
		return nil
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<E:Error>(expression: @autoclosure () throws -> Void, by handler:(E)->Void) -> Void {
	
	do {
		
		try expression()
	}
	catch let error as E {
		
		handler(error)
	}
	catch {
		
		fatalError("Unexpected Error: \(error)")
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R,E:Error>(expression: @autoclosure () throws -> R, by handler:(E)->Void) -> R? {
	
	do {
		
		return try expression()
	}
	catch let error as E {
		
		handler(error)
		
		return nil
	}
	catch {
		
		fatalError("Unexpected Error: \(error)")
	}
}

public protocol KeyValueChangeable {

	func withChangeValue(for keys: String...)
	func withChangeValue(for keys: String..., body: () -> Void)
	func withChangeValue<S: Sequence>(for keys: S, body: () -> Void)  where S.Element == String
}

//// FIXME: Xcode 7.3.1 からか、なぜか NSObject だけでなく NSViewController にも　KeyValueChangeable を適用しないと、その先で準拠性を約束できませんでした。
//extension NSViewController : KeyValueChangeable {
//}

extension NSObject : KeyValueChangeable {

	public func withChangeValue(for keys: String...) {
		
		withChangeValue(for: keys, body: {})
	}

	public func withChangeValue(for keys: String..., body: () -> Void) {

		withChangeValue(for: keys, body: body)
	}

	public func withChangeValue<S: Sequence>(for keys: S, body: () -> Void) where S.Element == String {
		
		keys.forEach(willChangeValue)
		
		defer {
			
			keys.forEach(didChangeValue)
		}
		
		body()
	}
}

public class ObjectKeeper<T:AnyObject> {

	public private(set) var instance:T?
	
	public init(_ instance:T) {

		self.instance = instance
	}
	
	public func release() {
		
		self.instance = nil
	}
}

public extension NSAppleEventDescriptor {
	
	var url: URL? {
		
		paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue.flatMap(URL.init(string:))
	}
}

@MainActor
public protocol AcknowledgementsIncluded {

	var acknowledgementsName: String! { get }
	var acknowledgementsBundle: Bundle? { get }
}

@MainActor
public protocol AcknowledgementsIncludedAndCustomizable : AcknowledgementsIncluded {
	
	var acknowledgementsName: String! { get set }
	var acknowledgementsBundle: Bundle? { get set }
}

extension AcknowledgementsIncluded {

	var acknowledgementsBundle: Bundle? {

		nil
	}
	
	var acknowledgements: Acknowledgements {

		Acknowledgements(name: acknowledgementsName, bundle: acknowledgementsBundle)!
	}
}

/// Acknowledgements for CocoaPods.
public struct Acknowledgements : Sendable {

	public struct Pod : Sendable {
	
		public var name: String
		public var license: String
	}
	
	public var pods: [Pod]
	public var headerText: String
	public var footerText: String
	
	public init?(name: String, bundle: Bundle?) {
	
		let bundle = bundle ?? Bundle.main
		
        guard let path = bundle.path(forResource: name, ofType: "plist") else {
			
			return nil
		}
		
		guard let acknowledgements = NSDictionary(contentsOfFile: path) else {
			
			return nil
		}
		
		guard let items = acknowledgements["PreferenceSpecifiers"] as? Array<Dictionary<String, String>> else {
			
			return nil
		}
		
		guard items.count > 2 else {
			
			return nil
		}
		
		pods = [Pod]()
		
		let header = items.first!
		let footer = items.last!
		
		headerText = header["FooterText"]!
		footerText = footer["FooterText"]!
		
		for item in items[items.startIndex + 1 ..< items.endIndex - 1] {
			
			let name = item["Title"]!
			let license = item["FooterText"]!
			
			pods.append(Pod(name: name, license: license))
		}
	}
}

extension Acknowledgements : CustomStringConvertible {
	
	public var description: String {
		
		var results = [String]()
		
		results.append(headerText)
		results.append("")
		
		for pod in pods {
			
			results.append("\(pod.name) : \(pod.license)")
		}
		
		results.append("")
		results.append(footerText)
		
        return results.joined(separator: "\n")
	}
}

// MARK: - Bundle

extension Bundle {
	
	public var appName: String? {
		
		let info = infoDictionary!
		
		if let name = info["CFBundleDisplayName"] as? String {
			
			return name
		}
		
		if let name = info["CFBundleName"] as? String {
			
			return name
		}
		
		return nil
	}
	
	public var appVersion:(main: String?, build: String?) {
		
		let info = infoDictionary!

		let main = info["CFBundleShortVersionString"] as? String
		let build = info["CFBundleVersion"] as? String
		
		return (main: main, build: build)
	}
	
	public var appCopyright: String? {
		
		infoDictionary!["NSHumanReadableCopyright"] as? String
	}
	
	public var appVersionString: String {
		
		let version = appVersion
		
		let main = version.main ?? ""
		let build = version.build.map { "build \($0)" } ?? ""
		
        let value = main.appendStringIfNotEmpty(string: build, separator: " ")

		return value
	}
}

// MARK: - Thread

private func ~= (pattern: DispatchQueue.Attributes, value: DispatchQueue.Attributes) -> Bool {
	
	pattern == value
}

//public struct Thread {
//	
//	public enum `Type` : RawRepresentable {
//		
//		case Serial
//		case Concurrent
//		
//		public init?(rawValue: dispatch_queue_attr_t!) {
//			
//			switch rawValue {
//				
//			case DISPATCH_QUEUE_CONCURRENT:
//				self = .Concurrent
//				
//			case DISPATCH_QUEUE_SERIAL:
//				self = .Serial
//				
//			default:
//				return nil
//			}
//		}
//		
//		public var rawValue:dispatch_queue_attr_t! {
//			
//			switch self {
//				
//			case .Concurrent:
//				return DISPATCH_QUEUE_CONCURRENT
//				
//			case .Serial:
//				return DISPATCH_QUEUE_SERIAL
//			}
//		}
//	}
//	
//	var queue: DispatchQueue
//	
//	public init(name: String, type: Type = .Serial) {
//
//		queue = DispatchQueue(name, type.rawValue)
//	}
//	
//	public func invokeAsync(predicate: @escaping () -> Void) {
//		
//		queue.async(execute: predicate)
//	}
//	
//	public func invoke<Result>(predicate: () -> Result) -> Result {
//		
//		queue.sync(execute: predicate)
//	}
//}

// MARK: - Capture

@MainActor
protocol Captureable {
	
	associatedtype CaptureTarget
	
	var captureTarget: CaptureTarget { get }
	
	func capture() -> NSImage
}

@MainActor
extension Captureable where CaptureTarget == NSView {

	func capture() -> NSImage {
	
        CodePiece.capture(view: captureTarget)
	}
	
	func capture(rect: NSRect) -> NSImage {
		
        CodePiece.capture(view: captureTarget, rect: rect)
	}
}

@MainActor
extension Captureable where CaptureTarget == NSWindow {
	
	func capture() -> NSImage {
		
        CodePiece.capture(window: captureTarget)
	}
}

extension NSView : Captureable {
	
	public var captureTarget: NSView {
		
		self
	}
}

extension NSView : HavingScale {
	
	public var scale: CGScale {
		
		(window?.backingScaleFactor).map(Scale.init) ?? .actual
	}
}

extension NSWindow : Captureable {
	
	public var captureTarget: NSWindow {
		
		self
	}
}

extension NSWindow : HavingScale {
	
	public var scale: CGScale {
		
		Scale(backingScaleFactor)
	}
}

extension NSView {
	
	var capturedImage: NSImage {
		
		capturedImage(inRect: bounds)
	}
	
	func capturedImage(inRect rect: NSRect) -> NSImage {
		
		guard rect != .zero else {

			fatalError("Bounds is Zero.")
		}

		let viewRect = bounds
		
		// Retina が混在した環境ではどの画面でも、サイズ情報はそのまま、ピクセルが倍解像度で得られるようです。
		// imageRep や、ここから生成した NSImage に対する操作は scale を加味しない座標系で問題ありませんが、
		// CGImage に対する処理は、スケールを加味した座標指定が必要になるようです。
		let imageRep = bitmapImageRepForCachingDisplay(in: viewRect)!

		cacheDisplay(in: viewRect, to: imageRep)
		
		let cgImage = imageRep.cgImage!
		let cgImageScale = cgImage.widthScale(of: viewRect.size)
		let scaledRect = rect.scaled(by: cgImageScale).rounded()
		
		let clippedImage = cgImage.cropping(to: scaledRect)!

		let image = NSImage(cgImage: clippedImage, size: scaledRect.size)

		// TODO: 画像の見やすさを考えて余白を作れたら良さそう。
		let horizontal = 0 // Int(max(image.size.height - image.size.width, 0) / 2.0)
		let vertical = 0 // Int(max(image.size.width - image.size.height, 0) / 2.0)
		
		let margin = Margin(vertical: vertical, horizontal: horizontal)
		let newImage = createImage(image: image, margin: margin)

		return newImage
	}
}

@available(*, renamed: "NSView.capturedImage")
func capture(view: NSView) -> NSImage { fatalError() }

@available(*, renamed: "NSView.capturedImage(inRect:)")
func capture(view: NSView, rect: NSRect) -> NSImage { fatalError() }


//extension Margin where Type : IntegerArithmeticType {
//	
//	public var horizontalTotal:Type {
//		
//		return self.left + self.right
//	}
//	
//	public var verticalTotal:Type {
//		
//		return self.top + self.bottom
//	}
//}

public func createImage(image: NSImage, margin: IntMargin) -> NSImage {

	let newWidth = Int(image.size.width) + margin.horizontalTotal
	let newHeight = Int(image.size.height) + margin.verticalTotal
	
	let bitsPerComponent = 8
	let bytesPerRow = 4 * newWidth
	let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
	
	let point = NSPoint(x: CGFloat(margin.left), y: CGFloat(margin.top))
	
    guard let bitmapContext = CGContext(data: nil, width: newWidth, height: newHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
		
		fatalError("Failed to create a bitmap context.")
	}
	
	
	let bitmapSize = NSSize(width: CGFloat(newWidth), height: CGFloat(newHeight))
	let bitmapRect = NSRect(origin: NSZeroPoint, size: NSSize(width: bitmapSize.width, height: bitmapSize.height))

    let graphicsContext = NSGraphicsContext(cgContext: bitmapContext, flipped: false)
	
	NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphicsContext
	
	image.draw(at: point, from: bitmapRect, operation: .copy, fraction: 1.0)

	NSGraphicsContext.restoreGraphicsState()
	
    guard let newImageRef = bitmapContext.makeImage() else {
		
		fatalError("Failed to create a bitmap with margin.")
	}

    let newImage = NSImage(cgImage: newImageRef, size: bitmapSize)
	
	return newImage
}

extension NSWindow {

	var capturedImage: NSImage {
		
		let windowId = CGWindowID(windowNumber)

		let imageRef = CGWindowListCreateImage(.zero, .optionIncludingWindow, windowId, [])
		let imageData = NSImage(cgImage: imageRef!, size: contentView!.bounds.size)
		
		return imageData
	}
}

@available(*, renamed: "NSWindow.capturedImage")
func capture(window: NSWindow) -> NSImage { fatalError() }

// MARK: - String

extension String {

	public func appendStringIfNotEmpty(string: String?, separator: String = "") -> String {
		
		guard let string = string, !string.isEmpty else {
			
			return self
		}
		
		return "\(self)\(separator)\(string)"
	}
}

extension APIKit.RequestError : CustomDebugStringConvertible {
	
	public var debugDescription: String {
		
		switch self {
			
		case .invalidBaseURL(let url):
			return "Invalid base URL: \(url)"
			
		case .unexpectedURLRequest(let request):
			return "Unexpected URL request: \(request)"
		}
	}
}

extension APIKit.ResponseError : CustomDebugStringConvertible {
	
	public var debugDescription: String {
		
		switch self {
			
		case .nonHTTPURLResponse(let response):
			return "Non HTTP URL Response: \(String(describing: response))"
			
		case .unacceptableStatusCode(let code):
			return "Unacceptable status code: \(code)"
			
		case .unexpectedObject(let object):
			return "Unexpected object: \(object)"
		}
	}
}

extension APIKit.SessionTaskError : CustomDebugStringConvertible {
	
	public var debugDescription: String {
		
		switch self {
			
		case .connectionError(let error):
			return "Connection error: \(error.localizedDescription)"
			
		case .requestError(let error):
			return "Request error: \(error.localizedDescription)"
			
		case .responseError(let error):
			return "Response error: \(error.localizedDescription)"
		}
	}
}

extension Range where Bound == String.Index {
	
	init?(_ range: NSRange, for text: String) {
		
		guard range.location != NSNotFound else {
		
			return nil
		}
		
		let start = text.index(text.startIndex, offsetBy: range.location)
		let end = text.index(start, offsetBy: range.length)
		
		self = start ..< end
	}
}

extension NSRegularExpression {

	func replaceAllMatches(onto text: inout String, options: NSRegularExpression.MatchingOptions = [], replacement: (String) throws -> String) rethrows {
		
		try replaceAllMatches(onto: &text) { text, _, _ in

			try replacement(text)
		}
	}
	
	func replaceAllMatches(onto text: inout String, options: NSRegularExpression.MatchingOptions = [], replacement: (String, inout Range<String.Index>, NSTextCheckingResult) throws -> String) rethrows {
		
		let range = NSRange(location: 0, length: text.count)
		
		for match in matches(in: text, options: options, range: range).reversed() {
			
			var range = Range(match.range, for: text)!
			let item = String(text[range])
			
			let newText = try replacement(item, &range, match)
			
			text = text.replacingCharacters(in: range, with: newText)
		}
	}
	
	func replaceAllMatches(onto text: inout String, options: NSRegularExpression.MatchingOptions = [], with replacement: String) {

		replaceAllMatches(onto: &text) { _ in replacement }
	}
}
