//
//  AcknowledgementsViewController.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on H27/07/31.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import Cocoa
import ESAppKitExtension

public final class ESAcknowledgementsTableViewDataSource : NSObject, NSTableViewDataSource {
	
	public private(set) weak var owner:ESAcknowledgementsViewController?
	public var acknowledgements:Acknowledgements
	
	public init(owner:ESAcknowledgementsViewController, acknowledgements:Acknowledgements) {
		
		self.owner = owner
		self.acknowledgements = acknowledgements

		super.init()
	}
	
	public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		
		return self.acknowledgements.pods.count
	}
	
	public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
		
		guard let owner = self.owner else {
		
			return nil
		}
		
		let pod = self.acknowledgements.pods[row]
		
		switch tableColumn!.identifier {
			
		case owner.nameColumnIdentifier:
			return pod.name
			
		case owner.licenseColumnIdentifier:
			return pod.license
			
		default:
			fatalError("Unknown column identifier (\(tableColumn?.identifier))")
		}
	}
}

public final class ESAcknowledgementsTableViewDelegate : NSObject, NSTableViewDelegate {
	
	public private(set) weak var owner:ESAcknowledgementsViewController?
	public var acknowledgements:Acknowledgements
	
	public init(owner:ESAcknowledgementsViewController, acknowledgements:Acknowledgements) {
		
		self.owner = owner
		self.acknowledgements = acknowledgements
		
		super.init()
	}
	
	public func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		let defaultCellHeight:CGFloat = tableView.rowHeight
		
		guard let owner = self.owner else {
			
			return defaultCellHeight
		}
		
		let pod = self.acknowledgements.pods[row]
		
		let column = tableView.columnWithIdentifier(owner.licenseColumnIdentifier)
		let columnView = tableView.tableColumnWithIdentifier("license")
		let columnRect = tableView.rectOfColumn(column)

		if let cell = columnView!.dataCell as? NSTextFieldCell {

			return pod.license.sizeWithFont(cell.font, lineBreakMode:NSLineBreakMode.ByWordWrapping, maxWidth: columnRect.width).height
		}
		else {
			
			return columnRect.height
		}
	}
}

public class ESAcknowledgementsViewController: NSViewController, AcknowledgementsIncludedAndCustomizable {

	@IBInspectable public var nameColumnIdentifier:String = "name"
	@IBInspectable public var licenseColumnIdentifier:String = "license"
	
	public var acknowledgementsName:String!
	public var acknowledgementsBundle:NSBundle?
	
	private var acknowledgementsTableViewDataSource:ESAcknowledgementsTableViewDataSource! {
		
		didSet {
			
			self.acknowledgementsTableView.setDataSource(self.acknowledgementsTableViewDataSource)
		}
	}
	
	private var acknowledgementsTableViewDelegate:ESAcknowledgementsTableViewDelegate! {
		
		didSet {
			
			self.acknowledgementsTableView.setDelegate(self.acknowledgementsTableViewDelegate)
		}
	}
	
	@IBOutlet public weak var acknowledgementsTableView:NSTableView! {
		
		didSet {
			
			self.acknowledgementsTableView.focusRingType = .None
		}
	}
	
    public override func viewDidLoad() {
		
        super.viewDidLoad()
	
		let headerText = acknowledgements.headerText
		
		if let title = NSBundle.mainBundle().appName {
			
			self.title = "\(title) : \(headerText)"
		}
		else {
			
			self.title = headerText
		}
	}
	
	public override func viewWillAppear() {

		super.viewWillAppear()
		
		let acknowledgements = self.acknowledgements
		
		if self.acknowledgementsTableView.dataSource() == nil {
			
			self.acknowledgementsTableViewDataSource = ESAcknowledgementsTableViewDataSource(owner: self, acknowledgements: acknowledgements)
		}
		
		if self.acknowledgementsTableView.delegate() == nil {
			
			self.acknowledgementsTableViewDelegate = ESAcknowledgementsTableViewDelegate(owner: self, acknowledgements: acknowledgements)
		}
    }
	
	public override func viewDidLayout() {
		
		super.viewDidLayout()
		
		self.acknowledgementsTableView.reloadData()
	}
}
