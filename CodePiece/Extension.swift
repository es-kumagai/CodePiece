//
//  Extension.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/21.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

// 将来的に別のモジュールへ移動できそうな機能を実装しています。

import APIKit
import Himotoki
import AppKit
import Ocean
import Swim
import ESCoreGraphicsExtension
import ESThread

public var OutputStream = StandardOutputStream()
public var ErrorStream = StandardErrorStream()
public var NullStream = NullOutputStream()

extension Optional {

	public func ifHasValue(@noescape predicate:(Wrapped) throws -> Void) rethrows {
		
		if case let value? = self {
			
			try predicate(value)
		}
	}
}

extension BooleanType {

	public func ifTrue(@noescape predicate:() throws -> Void) rethrows {
		
		if self {
			
			try predicate()
		}
	}
	
	public func ifFalse(@noescape predicate:() throws -> Void) rethrows {
		
		if !self {
			
			try predicate()
		}
	}
}

public class StandardOutputStream : OutputStreamType {
	
	public func write(string: String) {
		
		print(string)
	}
}

public class StandardErrorStream : OutputStreamType {
	
	public func write(string: String) {
		
		debugPrint(string)
	}
}

public class NullOutputStream : OutputStreamType {
	
	public func write(string: String) {
		
	}
}

extension Optional {
	
	public func invokeIfExists(@noescape expression:(Wrapped) throws -> Void) rethrows -> Void {
		
		if let value = self {

			try expression(value)
		}
	}
}

public func whether(@autoclosure condition:() throws -> Bool) rethrows -> YesNoState {
	
	return try condition() ? .Yes : .No
}

/// Execute `exression`. If an error occurred, write the error to standard output stream.
public func handleError(@autoclosure expression:() throws -> Void) -> Void {
	
	handleError(expression, to: &OutputStream)
}

/// Execute `exression`. If an error occurred, write the error to standard output stream.
public func handleError<R>(@autoclosure expression:() throws -> R) -> R? {

	return handleError(expression, to: &OutputStream)
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<STREAM:OutputStreamType>(@autoclosure expression:() throws -> Void, inout to stream:STREAM) -> Void {
	
	handleError(expression) { (error:ErrorType)->Void in
		
		stream.write("Error Handling: \(error)")
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R,STREAM:OutputStreamType>(@autoclosure expression:() throws -> R, inout to stream:STREAM) -> R? {
	
	return handleError(expression) { (error:ErrorType)->Void in
		
		stream.write("Error Handling: \(error)")
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError(@autoclosure expression:() throws -> Void, by handler:(ErrorType)->Void) -> Void {
	
	do {
		
		try expression()
	}
	catch {
		
		handler(error)
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<R>(@autoclosure expression:() throws -> R, by handler:(ErrorType)->Void) -> R? {
	
	do {
		
		return try expression()
	}
	catch {
		
		handler(error)
		
		return nil
	}
}

/// Execute `exression`. If an error occurred, write the error to `stream`.
public func handleError<E:ErrorType>(@autoclosure expression:() throws -> Void, by handler:(E)->Void) -> Void {
	
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
public func handleError<R,E:ErrorType>(@autoclosure expression:() throws -> R, by handler:(E)->Void) -> R? {
	
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

extension NSObject {

	public func withChangeValue(keys:String..., @noescape body:()->Void) {
		
		keys.forEach(self.willChangeValueForKey)
		
		defer {
			
			keys.forEach(self.didChangeValueForKey)
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
	
	public var url:NSURL? {
		
		return self.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue.flatMap { NSURL(string: $0) }
	}
}

public final class DebugTime {

	public static func print(message:String) {

		#if DEBUG
		NSLog("\(message)")
		#endif
	}
}

public protocol AcknowledgementsIncluded {

	var acknowledgementsName:String! { get }
	var acknowledgementsBundle:NSBundle? { get }
}

public protocol AcknowledgementsIncludedAndCustomizable : AcknowledgementsIncluded {
	
	var acknowledgementsName:String! { get set }
	var acknowledgementsBundle:NSBundle? { get set }
}

extension AcknowledgementsIncluded {

	var acknowledgementsBundle:NSBundle? {

		return nil
	}
	
	var acknowledgements:Acknowledgements {

		return Acknowledgements(name: self.acknowledgementsName, bundle: self.acknowledgementsBundle)!
	}
}

/// Acknowledgements for CocoaPods.
public struct Acknowledgements {

	public struct Pod {
	
		public var name:String
		public var license:String
	}
	
	public var pods:[Pod]
	public var headerText:String
	public var footerText:String
	
	public init?(name:String, bundle:NSBundle?) {
	
		let bundle = bundle ?? NSBundle.mainBundle()
		
		guard let path = bundle.pathForResource(name, ofType: "plist") else {
			
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
		
		self.pods = [Pod]()
		
		let header = items.first!
		let footer = items.last!
		
		self.headerText = header["FooterText"]!
		self.footerText = footer["FooterText"]!
		
		for item in items[items.startIndex.successor() ..< items.endIndex.predecessor()] {
			
			let name = item["Title"]!
			let license = item["FooterText"]!
			
			self.pods.append(Pod(name: name, license: license))
		}
	}
}

extension Acknowledgements : CustomStringConvertible {
	
	public var description:String {
		
		var results = [String]()
		
		results.append(self.headerText)
		results.append("")
		
		for pod in self.pods {
			
			results.append("\(pod.name) : \(pod.license)")
		}
		
		results.append("")
		results.append(self.footerText)
		
		return results.joinWithSeparator("\n")
	}
}

// MARK: - Bundle

extension NSBundle {
	
	public var appName:String? {
		
		let info = self.infoDictionary!
		
		if let name = info["CFBundleDisplayName"] as? String {
			
			return name
		}
		
		if let name = info["CFBundleName"] as? String {
			
			return name
		}
		
		return nil
	}
	
	public var appVersion:(main:String?, build:String?) {
		
		let info = self.infoDictionary!

		let main = info["CFBundleShortVersionString"] as? String
		let build = info["CFBundleVersion"] as? String
		
		return (main: main, build: build)
	}
	
	public var appCopyright:String? {
		
		return self.infoDictionary!["NSHumanReadableCopyright"] as? String
	}
	
	public var appVersionString:String {
		
		let version = self.appVersion
		
		let main = version.main ?? ""
		let build = version.build.map { "build \($0)" } ?? ""
		
		let value = main.appendStringIfNotEmpty(build, separator: " ")

		return value
	}
}

// MARK: - Thread

private func ~= (pattern:dispatch_queue_attr_t, value:dispatch_queue_attr_t) -> Bool {
	
	return pattern.isEqual(value)
}

public struct Thread {
	
	public enum Type : RawRepresentable {
		
		case Serial
		case Concurrent
		
		public init?(rawValue: dispatch_queue_attr_t!) {
			
			switch rawValue {
				
			case DISPATCH_QUEUE_CONCURRENT:
				self = .Concurrent
				
			case DISPATCH_QUEUE_SERIAL:
				self = .Serial
				
			default:
				return nil
			}
		}
		
		public var rawValue:dispatch_queue_attr_t! {
			
			switch self {
				
			case .Concurrent:
				return DISPATCH_QUEUE_CONCURRENT
				
			case .Serial:
				return DISPATCH_QUEUE_SERIAL
			}
		}
	}
	
	var queue:dispatch_queue_t
	
	public init(name:String, type:Type = .Serial) {
		
		self.queue = dispatch_queue_create(name, type.rawValue)
	}
	
	public func invokeAsync(predicate:()->Void) {
		
		ESThread.invokeAsync(self.queue, predicate: predicate)
	}
	
	public func invoke<Result>(predicate:()->Result) -> Result {
		
		return ESThread.invoke(self.queue, predicate: predicate)
	}
}

// MARK: - Capture

protocol Captureable {
	
	typealias CaptureTarget
	
	var captureTarget:CaptureTarget { get }
	
	func capture() -> NSImage
}

extension Captureable where CaptureTarget == NSView {

	func capture() -> NSImage {
	
		return CodePiece.capture(self.captureTarget)
	}
	
	func capture(rect:NSRect) -> NSImage {
		
		return CodePiece.capture(self.captureTarget, rect: rect)
	}
}

extension Captureable where CaptureTarget == NSWindow {
	
	func capture() -> NSImage {
		
		return CodePiece.capture(self.captureTarget)
	}
}

extension NSView : Captureable {
	
	public var captureTarget:NSView {
		
		return self
	}
}

extension NSView : EnclosingScaleProperty {
	
	public var scale:CGScale? {
		
		return (self.window?.backingScaleFactor).map(Scale.init)
	}
}

extension NSWindow : Captureable {
	
	public var captureTarget:NSWindow {
		
		return self
	}
}

extension NSWindow : EnclosingScaleProperty {
	
	public var scale:CGScale? {
		
		return Scale(self.backingScaleFactor)
	}
}

extension NSApplication : EnclosingScaleProperty {
	
	public var scale:CGScale? {
		
		return self.keyWindow?.scale
	}
}

func capture(view:NSView) -> NSImage {

	return capture(view, rect: view.bounds)
}

func capture(view:NSView, rect:NSRect) -> NSImage {
	
	guard rect != CGRectZero else {

		fatalError("Bounds is Zero.")
	}

	let viewRect = view.bounds
	
	// Retina が混在した環境ではどの画面でも、サイズ情報はそのまま、ピクセルが倍解像度で得られるようです。
	// imageRep や、ここから生成した NSImage に対する操作は scale を加味しない座標系で問題ありませんが、
	// CGImage に対する処理は、スケールを加味した座標指定が必要になるようです。
	let imageRep = view.bitmapImageRepForCachingDisplayInRect(viewRect)!

	view.cacheDisplayInRect(viewRect, toBitmapImageRep: imageRep)
	
	let cgImage = imageRep.CGImage!
	let cgImageScale = cgImage.widthScaleOf(viewRect.size)
	let scaledRect = rect.scaled(cgImageScale).truncate()
	
	let clippedImage = CGImageCreateWithImageInRect(cgImage, scaledRect)!

	let image = NSImage(CGImage: clippedImage, size: scaledRect.size)

	// TODO: 画像の見やすさを考えて余白を作れたら良さそう。
	let horizontal = 0 // Int(max(image.size.height - image.size.width, 0) / 2.0)
	let vertical = 0 // Int(max(image.size.width - image.size.height, 0) / 2.0)
	
	let margin = Margin(vertical: vertical, horizontal: horizontal)
	let newImage = createImage(image, margin: margin)

	return newImage
}


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

public func createImage(image:NSImage, margin:IntMargin) -> NSImage {

	let newWidth = Int(image.size.width) + margin.horizontalTotal
	let newHeight = Int(image.size.height) + margin.verticalTotal
	
	let bitsPerComponent = 8
	let bytesPerRow = 4 * newWidth
	let colorSpace = CGColorSpaceCreateDeviceRGB()
	let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
	
	let point = NSPoint(x: CGFloat(margin.left), y: CGFloat(margin.top))
	
	guard let bitmapContext = CGBitmapContextCreate(nil, newWidth, newHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue) else {
		
		fatalError("Failed to create a bitmap context.")
	}
	
	
	let bitmapSize = NSSize(width: CGFloat(newWidth), height: CGFloat(newHeight))
	let bitmapRect = NSRect(origin: NSZeroPoint, size: NSSize(width: bitmapSize.width, height: bitmapSize.height))

	let graphicsContext = NSGraphicsContext(CGContext: bitmapContext, flipped: false)
	
	NSGraphicsContext.saveGraphicsState()
	NSGraphicsContext.setCurrentContext(graphicsContext)
	
	image.drawAtPoint(point, fromRect: bitmapRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)

	NSGraphicsContext.restoreGraphicsState()
	
	guard let newImageRef = CGBitmapContextCreateImage(bitmapContext) else {
		
		fatalError("Failed to create a bitmap with margin.")
	}

	let newImage = NSImage(CGImage: newImageRef, size: bitmapSize)
	
	return newImage
}

func capture(window:NSWindow) -> NSImage {
	
	let windowId = CGWindowID(window.windowNumber)

	let imageRef = CGWindowListCreateImage(CGRectZero, CGWindowListOption.OptionIncludingWindow, windowId, CGWindowImageOption.Default)
	let imageData = NSImage(CGImage: imageRef!, size: window.contentView!.bounds.size)
	
	return imageData
}

// MARK: - String

extension String {

	public func appendStringIfNotEmpty(string:String?, separator:String = "") -> String {
		
		guard let string = string where !string.isEmpty else {
			
			return self
		}
		
		return "\(self)\(separator)\(string)"
	}
}

extension APIError : CustomDebugStringConvertible {
	
	public var debugDescription:String {
		
		switch self {
			
		case ConnectionError(let error):
			return error.localizedDescription
			
		case InvalidBaseURL(let url):
			return "Invalid base URL (\(url))"
			
		case ConfigurationError(let error):
			return "Configuration error (\(error))"
			
		case RequestBodySerializationError(let error):
			return "Request body serialization error (\(error))"
			
		case UnacceptableStatusCode(let code, let error):
			return "Unacceptable status code \(code) (\(error))"
			
		case ResponseBodyDeserializationError(let error):
			return "Response body deserialization error (\(error))"
			
		case InvalidResponseStructure(let object):
			return "Invalid response structure (\(object))"
			
		case NotHTTPURLResponse(let response):
			return "Not HTTP URL Response (\(response))"
		}
	}
}

extension DecodeError : CustomStringConvertible {
	
	public var description:String {
		
		switch self {
			
		case let .MissingKeyPath(keyPath):
			return "Missing KeyPath (\(keyPath))"
			
		case let .TypeMismatch(expected: expected, actual: actual, keyPath: keyPath):
			return "Type Mismatch (expected: \(expected), actual: \(actual), keyPath: \(keyPath))"
		}
	}
}