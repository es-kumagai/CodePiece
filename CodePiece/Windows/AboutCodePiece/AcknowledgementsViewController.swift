//
//  AcknowledgementsViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/31.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Sky

@preconcurrency import Cocoa

@objcMembers
final class ESAcknowledgementsTableViewDataSource : NSObject, NSTableViewDataSource {
	
	public private(set) weak var owner: ESAcknowledgementsViewController?
	public var acknowledgements: Acknowledgements
	
	public init(owner: ESAcknowledgementsViewController, acknowledgements: Acknowledgements) {
		
		self.owner = owner
		self.acknowledgements = acknowledgements

		super.init()
	}
	
	public func numberOfRows(in tableView: NSTableView) -> Int {
		
		acknowledgements.pods.count
	}
	
	public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

		guard let owner = owner else {
		
			return nil
		}
		
		guard let tableColumn = tableColumn else {
			
			return nil
		}

		let pod = acknowledgements.pods[row]
		let identifier = tableColumn.identifier
		
		#warning("blocking を Main Thread 限定にしてでも安定性を向上させたい。")
		return Task.blocking { () -> String? in
			
			switch identifier.rawValue {
				
			case await owner.nameColumnIdentifier:
				return pod.name
				
			case await owner.licenseColumnIdentifier:
				return pod.license
				
			default:
				fatalError("Unknown column identifier (\(identifier))")
			}
		}
	}
}

@objcMembers
final class ESAcknowledgementsTableViewDelegate : NSObject, NSTableViewDelegate {
	
	public private(set) weak var owner: ESAcknowledgementsViewController?
	public var acknowledgements:Acknowledgements
	
	public init(owner:ESAcknowledgementsViewController, acknowledgements:Acknowledgements) {
		
		self.owner = owner
		self.acknowledgements = acknowledgements
		
		super.init()
	}
	
	public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		let defaultCellHeight: CGFloat = Task.blocking { @MainActor in
			
			tableView.rowHeight
		}
		
		guard let owner = owner else {
			
			return defaultCellHeight
		}
		
		let pod = acknowledgements.pods[row]
		
#warning("blocking を Main Thread 限定にしてでも安定性を向上させたい。")
		return Task.blocking { @MainActor in
			
			let column = tableView.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: owner.licenseColumnIdentifier))
			let columnView = tableView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "license"))
			let columnRect = tableView.rect(ofColumn: column)

			if let cell = columnView!.dataCell as? NSTextFieldCell {

				return pod.license.size(with: cell.font, lineBreakMode: .byWordWrapping, maxWidth: columnRect.width).height
			}
			else {
				
				return columnRect.height
			}
		}
	}
}

// 以下に書き換えようとしたけれど `@IBInspectable を利用している意図を確かめられなかった保留します。
//extension NSUserInterfaceItemIdentifier {
//
//	static let acknowledgementsViewControllerNameColumn = NSUserInterfaceItemIdentifier(rawValue: "name")
//	static let acknowledgementsViewControllerLicenseColumn = NSUserInterfaceItemIdentifier(rawValue: "license")
//}

@objcMembers
@MainActor
final class ESAcknowledgementsViewController: NSViewController, AcknowledgementsIncludedAndCustomizable {

	@IBInspectable public dynamic var nameColumnIdentifier: String = "name"
	@IBInspectable public dynamic var licenseColumnIdentifier: String = "license"
	
	public var acknowledgementsName: String!
	public var acknowledgementsBundle: Bundle?
	
	private var acknowledgementsTableViewDataSource:ESAcknowledgementsTableViewDataSource! {
		
		didSet {
			
			acknowledgementsTableView.dataSource = acknowledgementsTableViewDataSource
		}
	}
	
	private var acknowledgementsTableViewDelegate:ESAcknowledgementsTableViewDelegate! {
		
		didSet {
			
			acknowledgementsTableView.delegate = acknowledgementsTableViewDelegate
		}
	}
	
	@IBOutlet public weak var acknowledgementsTableView:NSTableView! {
		
		didSet {
			
			acknowledgementsTableView.focusRingType = .none
		}
	}
	
    public override func viewDidLoad() {
		
        super.viewDidLoad()
	
		let headerText = acknowledgements.headerText
		
		if let title = Bundle.main.appName {
			
			self.title = "\(title) : \(headerText)"
		}
		else {
			
			self.title = headerText
		}
	}
	
	public override func viewWillAppear() {

		super.viewWillAppear()
		
		let acknowledgements = self.acknowledgements
		
		if acknowledgementsTableView.dataSource == nil {
			
			acknowledgementsTableViewDataSource = ESAcknowledgementsTableViewDataSource(owner: self, acknowledgements: acknowledgements)
		}
		
		if acknowledgementsTableView.delegate == nil {
			
			acknowledgementsTableViewDelegate = ESAcknowledgementsTableViewDelegate(owner: self, acknowledgements: acknowledgements)
		}
    }
	
	public override func viewDidLayout() {
		
		super.viewDidLayout()
		
		acknowledgementsTableView.reloadData()
	}
}
