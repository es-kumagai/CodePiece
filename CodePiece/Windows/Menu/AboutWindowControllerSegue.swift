//
//  AboutWindowControllerSegue.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/10.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import Swim

@objcMembers
@MainActor
final class AboutWindowControllerSegue : NSStoryboardSegue {
	
	@MainActor
	override func perform() {
		
		applyingExpression(to: destinationController as! AboutWindowController) {
			
			$0.acknowledgementsName = "Acknowledgements"
		}
		
		super.perform()
	}
}
