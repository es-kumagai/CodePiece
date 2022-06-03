//
//  TimelineTableView.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/10/07.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa

@objcMembers
@MainActor
final class TimelineTableView: NSTableView {

	// Infomation which tha table view has. if the cell for row is not maked yet, cell is set to nil.
	struct CellInfo {
		
		var row: Int
		var cell: TimelineTableCellView?
		var selection: Bool
	}
	
//	var selectedSingleOrMoreRows: Bool {
//		
//		return selectedRowIndexes.count > 0
//	}
//	
//	var selectedSingleRow: Bool {
//		
//		return selectedRowIndexes.count == 1
//	}
	
	var cells: [CellInfo] {
	
		let rows = 0 ..< numberOfRows
		
		return rows.reduce([CellInfo]()) { results, row in
			
			let cell = view(atColumn: 0, row: row, makeIfNecessary: false) as? TimelineTableCellView
			let selection = selectedRowIndexes.contains(row)
			
			return results + [CellInfo(row: row, cell: cell, selection: selection)]
		}
	}
	
	var selectedCells: [CellInfo] {
		
		return cells.filter { $0.selection }
	}
	
	var makedCells: [CellInfo] {
		
		return cells.filter { $0.isCellExists }
	}
	
	var selectedMakedCells: [CellInfo] {
		
		return makedCells.filter { $0.selection }
	}
	
//	func timelineTableDataSource() -> TimelineTableDataSource {
//
//		return super.dataSource as! TimelineTableDataSource
//	}
	
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		
		super.resize(withOldSuperviewSize: oldSize)
		
//		timelineTableDataSource().setNeedsEstimateHeight()
		reloadData()
	}
}

@MainActor
extension TimelineTableView.CellInfo {
	
	var isCellExists: Bool {
		
		cell != nil
	}
	
	func applySelection() {
		
		cell?.selected = selection
	}
}
