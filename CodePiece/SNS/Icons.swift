//
//  Icons.swift
//  ESTwitter
//
//  Created by Tomohiro Kumagai on 2020/03/04.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

@preconcurrency import class AppKit.NSImage
import ESTwitter
import Ocean


let twitterIconLoader = TwitterIconLoader()

// FIXME: 適切な非同期処理にする必要がある。現時点では Concurrency を活かせていない。
actor TwitterIconLoader {

	private var iconState = Dictionary<User, IconState>()
	
	func requestImage(for user: User) -> IconState {

		if let state = iconState[user] {
			
			return state
		}
		
		iconState[user] = .nowLoading
		
		Task {
			
			let image: NSImage?
			
			if let url = user.profile.imageUrlHttps.url {
			
				image = NSImage(contentsOf: url)
				iconState[user] = .image(image)
			}
			else {
				
				image = nil
				iconState[user] = nil
			}
			
			Task { @MainActor in

				TwitterIconDidLoadNotification(user: user, icon: image).post()
			}
		}
		
		return .nowLoading
	}
}

extension TwitterIconLoader {
	
	struct TwitterIconDidLoadNotification : NotificationProtocol, Sendable {
	
		var user: User
		var icon: NSImage?
	}
	
	enum IconState : Sendable {
	
		case image(NSImage?)
		case nowLoading
	}
}

extension TwitterIconLoader.IconState {
	
	@MainActor
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
	
	func loadImage(for user: User) async -> NSImage? {
		
		guard let url = user.profile.imageUrlHttps.url else {
		
			return nil
		}

		return await withCheckedContinuation { continuation in
			
			let image = NSImage(contentsOf: url)
				
			continuation.resume(returning: image)
		}
	}
}

