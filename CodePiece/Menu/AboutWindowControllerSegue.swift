//
//  AboutWindowControllerSegue.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/10.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Foundation
import Swim

final class AboutWindowControllerSegue : NSStoryboardSegue {
	
	override func perform() {
		
		tweak(self.destinationController as! AboutWindowController) {
			
			$0.acknowledgementsName = "Pods-CodePiece-acknowledgements"
		}
		
		super.perform()
	}
}
