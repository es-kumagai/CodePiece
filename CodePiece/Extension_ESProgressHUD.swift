//
//  Extension_ESProgressHUD.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/28.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import AppKit

public final class ProgressHUD {
	
	public typealias DismissHandler = (ProgressHUD) -> Void
	
	private weak var hudView:HUDView?
	private var dismissHandler:DismissHandler?
	
	private var shown:Bool {
		
		return self.hudView != nil
	}
	
	public var message:String?
	
	public var theme:Theme
	public var options:Options
	public var styles:Styles
	
	public init(message:String?, theme:Theme, options:Options? = nil, styles:Styles? = nil) {
		
		self.message = message
		
		self.theme = theme
		self.options = options ?? Options()
		self.styles = styles ?? Styles()
	}

	public convenience init(message:String? = nil, useActivityIndicator:Bool = false) {
	
		var options = Options()
		
		options.useActivityIndicator = useActivityIndicator
		
		self.init(message: message, theme: Themes.Basic.theme, options: options)
	}
	
	public func show(message:String? = nil, dismissHandler:DismissHandler? = nil) -> Bool {
		
		guard let targetView = ProgressHUD.targetViewInMainWindow else {
			
			return false
		}

		let frame = NSRect(x: 0.0, y: 0.0, width: 160.0, height: 160.0).centerOf(targetView.frame)
		let hudView = HUDView(frame: frame, owner:self, theme: self.theme, options: self.options, styles: self.styles)
		
		hudView.message = message ?? self.message ?? ""
		
		dispatch_async(dispatch_get_main_queue()) {

			self.hudView = hudView
			self.dismissHandler = dismissHandler
			
			targetView.addSubview(hudView)
		}
		
		return true
	}
	
	public func hide() {
		
		dispatch_async(dispatch_get_main_queue()) {
			
			self.hudView?.removeFromSuperview()

			defer {

				self.hudView = nil
				self.dismissHandler = nil
			}
			
			self.dismissHandler?(self)
		}
	}
}

extension ProgressHUD {
	
	public struct Options {
		
		public var useActivityIndicator:Bool = false
		public var keepPopupWhenTouch:Bool = true
	}
	
	public struct Theme {
		
		public var textColor:NSColor
		public var backgroundColor:NSColor
		
		init(textColor:NSColor, backgroundColor:NSColor) {
			
			self.textColor = textColor
			self.backgroundColor = backgroundColor
		}
	}
	
	public struct Styles {
		
		public var font:NSFont = NSFont.systemFontOfSize(16.0)
		public var padding:Margin<CGFloat> = Margin<CGFloat>(margin: 8.0)
		public var radius:CGFloat = 8.0
	}
}

extension ProgressHUD {

	public enum Themes {
		
		case Basic
		
		public var theme:Theme {
			
			switch self {
				
			case .Basic:
				return Theme(textColor: NSColor.blackColor(), backgroundColor: NSColor(white: 0.8, alpha: 0.90))
			}
		}
	}
}

private final class HUDView : NSView {

	private(set) weak var owner:ProgressHUD?
	
	private var messageLabel:NSTextField!
	private var progressIndicator:NSProgressIndicator!
	
	var message:String {
	
		get {
			
			return self.messageLabel.stringValue
		}
		
		set {
			
			self.messageLabel.stringValue = newValue
			self.updateFrames()
		}
	}
	
	var theme:ProgressHUD.Theme! {
		
		didSet {
			
			self.applyTheme(self.theme)
		}
	}
	
	var options:ProgressHUD.Options! {
		
		didSet {
			
			self.applyOptions(self.options)
		}
	}
	
	var styles:ProgressHUD.Styles! {
	
		didSet {
			
			self.applyStyles(self.styles)
		}
	}
	
	init(frame frameRect: NSRect, owner:ProgressHUD, theme:ProgressHUD.Theme, options:ProgressHUD.Options, styles:ProgressHUD.Styles) {
		
		self.owner = owner
		
		super.init(frame: frameRect)

		HUDView.prepare(self)
		
		self.theme = theme
		self.options = options
		self.styles = styles
		
		self.applyTheme(theme)
		self.applyOptions(options)
		self.applyStyles(styles)
	}

	required init?(coder: NSCoder) {
		
	    fatalError("init(coder:) has not been implemented")
	}
	
	private func applyTheme(theme:ProgressHUD.Theme) {
		
		self.messageLabel.textColor = theme.textColor
		self.layer!.backgroundColor = theme.backgroundColor.CGColor
	}
	
	private func applyOptions(options:ProgressHUD.Options) {
	
		if options.useActivityIndicator {
			
			self.progressIndicator.startAnimation(self)
		}
		else {
			
			self.progressIndicator.stopAnimation(self)
		}
	}
	
	private func applyStyles(styles:ProgressHUD.Styles) {
		
		self.layer!.cornerRadius = styles.radius
		self.messageLabel.font = styles.font
		
		self.updateFrames()
	}
	
	private func updateMessageLabelFrame(parentFrame frame:CGRect? = nil) {

		var attributes = [String:AnyObject!]()
		
		if let font = self.messageLabel.font {
			
			attributes[NSFontAttributeName] = font
		}
		
		let size = NSAttributedString(string: self.messageLabel.stringValue, attributes: attributes).boundingRectWithSize(messageLabel.bounds.size.replaced(height: 0.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin)
		
		self.messageLabel.frame = self.messageLabel.frame.replaced(height: size.height)
	}
	
	private func updateFrames(parentFrame frame:CGRect? = nil) {

		guard let frame = frame ?? self.superview?.frame else {
			
			return
		}

		self.updateMessageLabelFrame()
		
		var messageLabelFrame = self.messageLabel.frame.centerOf(frame)
		
		if self.options.useActivityIndicator {

			let halfMargin:CGFloat = 4.0
			var progressIndicatorFrame = self.progressIndicator.frame.centerOf(frame)

			progressIndicatorFrame.origin.y += messageLabelFrame.size.height.halfValue.truncate() + halfMargin
			messageLabelFrame.origin.y -= progressIndicatorFrame.size.height.halfValue.truncate() + halfMargin
			
			self.messageLabel.frame = messageLabelFrame
			self.progressIndicator.frame = progressIndicatorFrame
		}
		else {

			self.messageLabel.frame = messageLabelFrame
		}
	}

	var backgroundColor:NSColor? {
	
		get {

			return self.layer!.backgroundColor.flatMap(NSColor.init)
		}
		
		set {
			
			self.layer?.backgroundColor = newValue?.CGColor
		}
	}
	
	override func layout() {

		defer {

			super.layout()
		}
		
		self.updateFrames(parentFrame: self.frame)
		
		self.addSubview(self.messageLabel)
		self.addSubview(self.progressIndicator)
	}
}

extension HUDView {
	
	private static func prepare(view:HUDView) {
		
		view.wantsLayer = true
		view.focusRingType = NSFocusRingType.None
		view.layer!.zPosition = 1003

		self.prepareMessageLabel(view)
		self.prepareProgressIndicator(view)
	}
	
	private static func prepareMessageLabel(view:HUDView) {
		
		let viewFrame = view.frame
		let labelFrame = view.frame.applyPadding(Margin(margin: 8.0)).replaced(height: 50.0).centerOf(viewFrame)
		
		view.messageLabel = NSTextField(frame: labelFrame)
		
		view.messageLabel.editable = false
		view.messageLabel.bordered = false
		view.messageLabel.backgroundColor = NSColor.clearColor()
		view.messageLabel.alignment = NSTextAlignment.Center
	}
	
	private static func prepareProgressIndicator(view:HUDView) {
		
		let size:CGFloat = 32.0
		let frame = NSRect(x: 0.0, y: 0.0, width: size, height: size)
		
		view.progressIndicator = NSProgressIndicator(frame: frame)
		view.progressIndicator.style = NSProgressIndicatorStyle.SpinningStyle
		view.progressIndicator.displayedWhenStopped = false
	}
}

extension HUDView {

	override func mouseDown(theEvent: NSEvent) {
		
		super.mouseDown(theEvent)
		
		self.window?.nextEventMatchingMask(Int(NSEventType.LeftMouseUp.rawValue))
	}

	override func mouseUp(theEvent: NSEvent) {
		
		super.mouseUp(theEvent)
		
		if !self.options.keepPopupWhenTouch {

			self.owner?.hide()
		}
	}
}

extension ProgressHUD {

	private static var targetViewInMainWindow:NSView? {
		
		let application = NSApplication.sharedApplication()

		if let window = application.keyWindow where window.visible {
			
			return window.contentView
		}
		
		if let window = application.mainWindow where window.visible {
			
			return window.contentView
		}
		
		if let window = NSApplication.sharedApplication().windows.findElement({ $0.visible })?.element {
			
			return window.contentView
		}
		
		return nil
	}
}