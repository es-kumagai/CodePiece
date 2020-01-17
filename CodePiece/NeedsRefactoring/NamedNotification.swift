//
//  NamedNotification.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2020/01/17.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

#warning("上手くできたら Ocean フレームワークに移行します。と思ったが、不要だった。observe(notificationNamed: でいけた。")

//import Foundation
//import Ocean
//
///// This Notification represent almost the same thing as NSNotification.
//public class NamedNotification : NSObject, NotificationProtocol {
//
//	public typealias UserInfo = [AnyHashable : Any]
//
//	public private(set) var name: Foundation.Notification.Name
//	public private(set) var object: Any?
//	public private(set) var userInfo: UserInfo?
//
//	public convenience init(name: Foundation.Notification.Name) {
//
//		self.init(name: name, object: nil, userInfo: nil)
//	}
//
//	public convenience init(name: Foundation.Notification.Name, object: Any?) {
//
//		self.init(name: name, object: object, userInfo: nil)
//	}
//
//	public init(name: Foundation.Notification.Name, object: Any?, userInfo: UserInfo?) {
//
//		self.name = name
//		self.object = object
//		self.userInfo = userInfo
//
//		super.init()
//	}
//
//	/// Initialize with a Raw Notification.
//	public convenience init(_ rawNotification: Foundation.Notification) {
//
//		self.init(name: rawNotification.name, object: rawNotification.object, userInfo: rawNotification.userInfo)
//	}
//
//	/// Get a Raw Notification.
//	public var rawNotification: Foundation.Notification {
//
//		return Foundation.Notification(name: name, object: object, userInfo: userInfo)
//	}
//}
//
//extension NamedNotification {
//
//	public override var description: String {
//
//		return "\(NamedNotification.self)(\(self.name))"
//	}
//}
