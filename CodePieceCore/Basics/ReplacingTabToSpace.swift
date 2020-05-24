//
//  String.swift
//  CodePieceCore
//
//  Created by kumagai on 2020/05/24.
//  Copyright © 2020 Tomohiro Kumagai. All rights reserved.
//

import Foundation

extension StringProtocol {
	
	/// タブをスペースに置き換えます。
	/// - Parameters:
	///   - lines: 置き換え対象のソースコードです。
	///   - spacesPerTab: タブ１つあたりの空白の数です。
	/// - Returns: タブをスペースに置き換えた後の文字列です。
	public func replacingTabToSpace(spacesPerTab: Int) -> String {

		return replacingOccurrences(of: "\t", with: String(repeating: " ", count: spacesPerTab))
	}
}

extension Sequence where Element : StringProtocol {
	
	/// タブをスペースに置き換えます。
	/// - Parameter spacesPerTab: タブ１つあたりの空白の数です。
	/// - Returns: タブをスペースに置き換えた後の文字列です。
	public func replacingTabToSpace(spacesPerTab: Int) -> [String] {
		
		return map { $0.replacingTabToSpace(spacesPerTab: spacesPerTab) }
	}
}
