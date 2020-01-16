//
//  CaptureInfo.swift
//  CodePiece
//
//  Created by Tomohiro Kumagai on 2/28/16.
//  Copyright © 2016 EasyStyle G.K. All rights reserved.
//

import WebKit

protocol CaptureInfoType {
	
	var userAgent: String? { get }
	var targetNode: (WebView, DOMDocument) -> DOMNode? { get }
	var clientSize: NSSize { get }
}

struct SimpleCaptureInfo : CaptureInfoType {
	
	let userAgent: String? = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"
	let clientSize: NSSize = NSMakeSize(560.0, 560.0)

	var targetNode: (WebView, DOMDocument) -> DOMNode? {
		
		return { webview, dom in
			
			return dom.getElementsByClassName("blob-file-content").item(0)
		}
	}
}

struct LinedCaptureInfo : CaptureInfoType {
	
	let userAgent: String? = nil
	let clientSize: NSSize = NSMakeSize(480.0, 480.0)
	
	var targetNode: (WebView, DOMDocument) -> DOMNode? {
		
		return { webview, dom in
		
			let nodes = dom.getElementsByClassName("data")!
			let	node = nodes.item(0) as Optional
		
			let applyingStyleScript = [
				
				"var tableNode = document.getElementsByTagName('table')[0];",
				
				"tableNode.style.tabSize = '4';",
				
				"var containerNode = document.getElementById('file-codepiece-swift');",
				"var searchNodes = containerNode.getElementsByTagName('div');",
				
				"for (var i = 0; i != searchNodes.length; ++i) {",
				
				"    var node = searchNodes[i];",
				
				"    if (node.getAttribute('itemprop') == 'text') {",
				
				"        node.style.tabSize = '4';",
				"        node.style.border = 'thin solid #f7f7f7';",
				"        node.style.padding = '6px';",
				"        node.style.width = '\(self.clientSize.width)px';",
				"        break;",
				"    }",
				"}",
				
				"var numberNodes = tableNode.getElementsByClassName('blob-num');",
				
				"for (var i = 0; i != numberNodes.length; ++i) {",
				
				"    var node = numberNodes[i];",
				
				"    node.style.minWidth = '0px';",
				"}"
			]
			
			webview.stringByEvaluatingJavaScript(from: applyingStyleScript.joined(separator: "\n"))
		
			return node
		}
	}
}
