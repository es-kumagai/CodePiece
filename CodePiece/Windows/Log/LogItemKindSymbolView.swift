//
//  LogItemKindSymbolView.swift
//  CodePiece
//  
//  Created by Tomohiro Kumagai on 2022/09/29
//  Copyright © 2022 Tomohiro Kumagai. All rights reserved.
//

import SwiftUI

extension LogItem.Kind {
	
	//	FIXME: LogItemKind の種類によってカスタムビューを提供したかったのですが、目的を達成できていません。
	//	some View を汎用的に取り扱うと any View になり、それを viewBuilder で使えないため、拡張性を持たせたかったので試行中ですが、それを犠牲にして LogItemKind 自体を enum にすれば決着はします。
	struct SymbolView : View {
		
		let item: LogItemKind
		
		var body: some View {
			
			EmptyView()
		}
	}
}
