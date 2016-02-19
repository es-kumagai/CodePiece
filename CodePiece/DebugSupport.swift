//
//  DebugSupport.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2016/02/13.
//  Copyright © 2016年 EasyStyle G.K. All rights reserved.
//

#if DEBUG

	import Foundation
	
	func debugStringFromJSON(object: AnyObject) -> String {
		
		guard let data = try? NSJSONSerialization.dataWithJSONObject(object, options: []) else {
			
			return "*** FAILED TO DECODE *** \n\(object)"
		}
		
		guard let string = String(data: data, encoding: NSUTF8StringEncoding) else {
			
			return "*** FAILED TO DECODE *** \n\(data)"
		}
		
		return string
	}
	
#endif
