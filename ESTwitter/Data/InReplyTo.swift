//
//  InReplyTo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct InReplyTo {
	
	public var userIdStr:String
	public var statusIdStr:String
	public var userId:UInt64
	public var screenName:String
	public var statusId:UInt64
}

extension InReplyTo : Decodable {
	
	public static func decode(e: Extractor) throws -> InReplyTo {
		
		return try InReplyTo(
			
			userIdStr: e.value("in_reply_to_user_id_str"),
			statusIdStr: e.value("in_reply_to_status_id_str"),
			userId: e.value("in_reply_to_user_id"),
			screenName: e.value("in_reply_to_screen_name"),
			statusId: e.value("in_reply_to_status_id")
		)
	}
	
	public static func decodeOptional(e: Extractor) throws -> InReplyTo? {
		
		do {
			
			return try self.decode(e)
		}
		catch DecodeError.MissingKeyPath {
			
			return nil
		}
	}
}
