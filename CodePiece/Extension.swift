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

// MARK: - General

public protocol Zeroable {

	static var zero:Self { get }
	var isZero:Bool { get }
	
}

extension Zeroable {

	public func nonZeroMap<Result:Zeroable>(predicate:(Self) throws -> Result) rethrows -> Result {

		if self.isZero {
			
			return Result.zero
		}
		else {
			
			return try predicate(self)
		}
	}
}

extension Zeroable where Self : Equatable {

	public var isZero:Bool {

		return self == Self.zero
	}
}

extension IntegerType where Self : Zeroable {
	
	public static var zero:Self {
		
		return 0
	}
}

extension String.CharacterView.Index.Distance : Zeroable {
	
	public static var zero:String.CharacterView.Index.Distance {
		
		return 0
	}
	
	public var isZero:Bool {
		
		return self == String.CharacterView.Index.Distance.zero
	}
}

extension String : Zeroable {
	
	public static var zero:String {
		
		return ""
	}
	
	public var isZero:Bool {
		
		return self.isEmpty
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
		
		Ocean.invokeAsync(self.queue, predicate: predicate)
	}
	
	public func invoke<Result>(predicate:()->Result) -> Result {
		
		return Ocean.invokeSync(self.queue, predicate: predicate)
	}
}

// MARK: - Capture

func flip(rect:NSRect, height:CGFloat) -> NSRect {

	let origin = flip(rect.origin, height: height - rect.height)
	let size = rect.size
	
	return NSMakeRect(origin.x, origin.y, size.width, size.height)
}

func flip(point:NSPoint, height:CGFloat) -> NSPoint {
	
	return NSMakePoint(point.x, height - point.y)
}

public struct Scale {
	
	public var value:CGFloat
	
	public init(_ value:CGFloat) {
		
		self.value = value
	}
}

extension Scale {

	public var isSameMagnification:Bool {
	
		return self.value == 1.0
	}
	
	public func applyTo<Value:Scaleable>(value:Value) -> Value {
		
		return value.scaled(self)
	}
}

extension Scale : IntegerLiteralConvertible {
	
	public init(integerLiteral value: Int) {

		self.init(CGFloat(value))
	}
}

extension Scale : FloatLiteralConvertible {
	
	public init(floatLiteral value: Double) {

		self.init(CGFloat(value))
	}
}

extension Scale : Equatable {
	
}

extension Scale : CustomStringConvertible {
	
	public var description:String {
		
		return self.value.description
	}
}

public func == (lhs:Scale, rhs:Scale) -> Bool {
	
	return lhs.value == rhs.value
}

public protocol Scaleable {
	
	func scaled(scale:Scale) -> Self
}

extension Scaleable {

	func scaledBy<T:EnclosingScaleProperty>(item:T) -> Self {

		guard let scale = item.scale else {

			fatalError("Cannot get a scale of \(item).")
		}
		
		return self.scaled(scale)
	}
}

public protocol EnclosingScaleProperty {

	var scale:Scale? { get }
}

public protocol Truncateable {
	
	func truncate() -> Self
}

extension Truncateable {

	public func truncate(ifNeed:Bool) -> Self {
	
		if ifNeed {

			return self.truncate()
		}
		else {
	
			return self
		}
	}
}

extension SignedIntegerType where Self : Scaleable {
	
	public func scaled(scale: Scale) -> Self {

		return Self(self.toIntMax() * IntMax(scale.value))
	}
}

extension UnsignedIntegerType where Self : Scaleable {
	
	public func scaled(scale: Scale) -> Self {
		
		return Self(self.toUIntMax() * UIntMax(scale.value))
	}
}

extension CGFloat : Scaleable, Truncateable {
	
	public func scaled(scale: Scale) -> CGFloat {
		
		return self * scale.value
	}
	
	public func truncate() -> CGFloat {
		
		return CGFloat(IntMax(self))
	}
}

extension Double : Scaleable, Truncateable {
	
	public func scaled(scale: Scale) -> Double {
		
		return self * Double(scale.value)
	}
	
	public func truncate() -> Double {
		
		return Double(IntMax(self))
	}
}

extension Float : Scaleable, Truncateable {
	
	public func scaled(scale: Scale) -> Float {
		
		return self * Float(scale.value)
	}
	
	public func truncate() -> Float {
		
		return Float(IntMax(self))
	}
}

extension Float80 : Scaleable, Truncateable {
	
	public func scaled(scale: Scale) -> Float80 {
		
		return self * Float80(Float(scale.value))
	}
	
	public func truncate() -> Float80 {
		
		return Float80(IntMax(self))
	}
}

extension CGPoint : Scaleable, Truncateable {
	
	public func scaled(scale:Scale) -> CGPoint {
		
		guard !scale.isSameMagnification else {
		
			return self
		}
		
		let x = self.x.scaled(scale)
		let y = self.y.scaled(scale)
		
		return CGPoint(x: x, y: y)
	}
	
	public func truncate() -> CGPoint {
		
		let x = self.x.truncate()
		let y = self.y.truncate()
		
		return CGPoint(x: x, y: y)
	}
}

extension CGSize : Scaleable, Truncateable {
	
	public func scaled(scale:Scale) -> CGSize {
		
		guard !scale.isSameMagnification else {
			
			return self
		}
		
		let width = self.width.scaled(scale)
		let height = self.height.scaled(scale)
		
		return CGSize(width: width, height: height)
	}
	
	public func truncate() -> CGSize {
		
		let width = self.width.truncate()
		let height = self.height.truncate()
		
		return CGSize(width: width, height: height)
	}
}

extension CGRect : Scaleable, Truncateable {
	
	public func scaled(scale:Scale) -> CGRect {
		
		guard !scale.isSameMagnification else {
			
			return self
		}
		
		let origin = self.origin.scaled(scale)
		let size = self.size.scaled(scale)
		
		return CGRect(origin: origin, size: size)
	}
	
	public func truncate() -> CGRect {
		
		let origin = self.origin.truncate()
		let size = self.size.truncate()
		
		return CGRect(origin: origin, size: size)
	}
}

extension CGFloat {
	
	public func scaleOf(value:CGFloat) -> Scale {
		
		return Scale(self / value)
	}
	
}

extension CGSize {
	
	public func widthScaleOf(size:CGSize) -> Scale {
		
		return self.width.scaleOf(size.width)
	}
	
	public func heightScaleOf(size:CGSize) -> Scale {
		
		return self.height.scaleOf(size.height)
	}
}

extension CGRect {
	
	public func widthScaleOf(rect:CGRect) -> Scale {
		
		return self.size.widthScaleOf(rect.size)
	}
	
	public func heightScaleOf(rect:CGRect) -> Scale {
		
		return self.size.heightScaleOf(rect.size)
	}
}

extension CGImage {
	
	public func widthScaleOf(size:CGSize) -> Scale {
		
		return CGFloat(CGImageGetWidth(self)).scaleOf(size.width)
	}
	
	public func heightScaleOf(size:CGSize) -> Scale {
		
		return CGFloat(CGImageGetHeight(self)).scaleOf(size.height)
	}
}

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
	
	public var scale:Scale? {
		
		return (self.window?.backingScaleFactor).map(Scale.init)
	}
}

extension NSWindow : Captureable {
	
	public var captureTarget:NSWindow {
		
		return self
	}
}

extension NSWindow : EnclosingScaleProperty {
	
	public var scale:Scale? {
		
		return Scale(self.backingScaleFactor)
	}
}

extension NSApplication : EnclosingScaleProperty {
	
	public var scale:Scale? {
		
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

public struct Margin<Type> {

	public var top:Type
	public var right:Type
	public var bottom:Type
	public var left:Type
	
	public init(top:Type, right:Type, bottom:Type, left:Type) {
		
		self.top = top
		self.right = right
		self.bottom = bottom
		self.left = left
	}
	
	public init(margin:Type) {
		
		self.init(top: margin, right: margin, bottom: margin, left: margin)
	}
	
	public init(vertical:Type, horizontal:Type) {
		
		self.init(top: vertical, right: horizontal, bottom: vertical, left: horizontal)
	}
	
	public init(top:Type, horizontal:Type, bottom:Type) {
		
		self.init(top: top, right: horizontal, bottom: bottom, left: horizontal)
	}
}

extension Margin where Type : IntegerArithmeticType {
	
	public var horizontalTotal:Type {
		
		return self.left + self.right
	}
	
	public var verticalTotal:Type {
		
		return self.top + self.bottom
	}
}

extension CGPoint {
	
	public init(x:Int, y:Int) {
		
		self.init(x: CGFloat(x), y: CGFloat(y))
	}
}

extension CGSize {
	
	public init(width:Int, height:Int) {
		
		self.init(width: CGFloat(width), height: CGFloat(height))
	}
}

func createImage(image:NSImage, margin:Margin<Int>) -> NSImage {

	let newWidth = Int(image.size.width) + margin.horizontalTotal
	let newHeight = Int(image.size.height) + margin.verticalTotal
	
	let bitsPerComponent = 8
	let bytesPerRow = 4 * newWidth
	let colorSpace = CGColorSpaceCreateDeviceRGB()
	let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
	
	let point = NSPoint(x: margin.left, y: margin.top)
	
	guard let bitmapContext = CGBitmapContextCreate(nil, newWidth, newHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue) else {
		
		fatalError("Failed to create a bitmap context.")
	}
	
	
	let bitmapSize = NSSize(width: newWidth, height: newHeight)
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
	let imageData = NSImage(CGImage: imageRef!, size: window.contentView.bounds.size)
	
	return imageData
}

// MARK: - String

extension String {

	public func trimmed() -> String {
	
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
	
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
