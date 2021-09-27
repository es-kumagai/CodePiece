//
//  CodingTests.swift
//  ESTwitterTests
//
//  Created by Tomohiro Kumagai on 2021/09/27.
//  Copyright © 2021 Tomohiro Kumagai. All rights reserved.
//

import XCTest
@testable import ESTwitter

private struct Statuses : Decodable {
	
	var statuses: [Status]
}

class CodingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecoding() throws {

		let rawDataUrl = Bundle(for: Self.self).url(forResource: "Tweets-raw.20210927", withExtension: "data")!
		let swifterDataUrl = Bundle(for: Self.self).url(forResource: "Tweets-Swifter.20210927", withExtension: "data")!

		let rawData = try Data(contentsOf: rawDataUrl)
		let rawJson = try JSONSerialization.jsonObject(with: rawData)

		XCTAssertTrue(JSONSerialization.isValidJSONObject(rawJson))

		let statusFromRaw = try JSONDecoder().decode(Statuses.self, from: rawData)

		XCTAssertEqual(statusFromRaw.statuses.count, 15)

		
		let swifterData = try Data(contentsOf: swifterDataUrl).reduce(into: Data()) { data, byte in

			// Ignore Backspaces to pass the process of JSONSerialization.
			if byte != 0x08 {
				
				data.append(byte)
			}
		}
		let swifterJson = try JSONSerialization.jsonObject(with: swifterData)

		XCTAssertTrue(JSONSerialization.isValidJSONObject(swifterJson))

		let statusFromSwifter = try JSONDecoder().decode([Status].self, from: swifterData)

		XCTAssertEqual(statusFromSwifter.count, 15)
	}
}
