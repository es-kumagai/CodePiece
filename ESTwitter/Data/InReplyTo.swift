//
//  InReplyTo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/04.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

public struct InReplyTo : Decodable {
	
	public var userIdStr: String
	public var statusIdStr: String
	public var userId: UInt64
	public var screenName: String
	public var statusId: UInt64
}

extension InReplyTo {

	public enum CodingKeys : String, CodingKey {
		
		case userIdStr = "in_reply_to_user_id_str"
		case statusIdStr = "in_reply_to_status_id_str"
		case userId = "in_reply_to_user_id"
		case screenName = "in_reply_to_screen_name"
		case statusId = "in_reply_to_status_id"
	}
}
