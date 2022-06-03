//
//  SearchTweetsWindowControllerDelegate.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2021/08/09.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import Foundation

@MainActor
@objc protocol SearchTweetsWindowControllerDelegate : AnyObject {
	
	@objc func searchTweetsWindowControllerWillClose(_ sender: SearchTweetsWindowController)
}
