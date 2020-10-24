//
//  Icons.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/03/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import AppKit
import ESTwitter
import Ocean


let twitterIconLoader = TwitterIconLoader()

class TwitterIconLoader {

	struct TwitterIconDidLoadNotification : NotificationProtocol {
	
		var user: User
		var icon: NSImage?
	}
	
	enum IconState {
	
		case image(NSImage)
		case nowLoading
	}
	
	private var processingQueue = DispatchQueue(label: "jp.ez-net.codepiece.twitter.iconloader")
	private var iconState = Dictionary<User, IconState>()
	
	func requestImage(for user: User) -> IconState {

		processingQueue.sync { [unowned self] in

			if let state = iconState[user] {
				
				return state
			}
			
			iconState[user] = .nowLoading
			
			loadImage(for: user) {
				
				imageLoaded(for: user, image: $0)
			}
			
			return .nowLoading
		}
	}
}

extension TwitterIconLoader.IconState {
	
	var image: NSImage? {
		
		switch self {
			
		case .image(let image):
			return image
			
		case .nowLoading:
			return nil
		}
	}
}

private extension TwitterIconLoader {
	
	func imageLoaded(for user: User, image: NSImage?) {
		
		switch image {
			
		case .some(let image):
			iconState[user] = .image(image)
			
		case .none:
			iconState[user] = nil
		}

		DispatchQueue.main.async {

			TwitterIconDidLoadNotification(user: user, icon: image).post()
		}
	}
	
	func loadImage(for user: User, callback: @escaping (NSImage?) -> Void) {
		
		guard let url = user.profile.imageUrlHttps.url else {
		
			callback(nil)
			return
		}
		
		DispatchQueue.global(qos: .background).async { [unowned self] in
			
			let image = NSImage(contentsOf: url)
			
			processingQueue.async {
				
				callback(image)
			}
		}
	}
}

