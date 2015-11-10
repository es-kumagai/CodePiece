//
//  MainWindowUITests.swift
//  MainWindowUITests
//
//  Created by Tomohiro Kumagai on H27/10/08.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

import XCTest

class MainWindowUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
		
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

		// In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testAboutWindowController() {
		
		let app = XCUIApplication()
		
		app.launch()

		let mainWindow = app.windows["CodePiece"]
		let menuBarsQuery = app.menuBars
		let aboutWindow = app.dialogs["Untitled"]
		
		XCTAssertTrue(mainWindow.exists)
		XCTAssertFalse(aboutWindow.exists)
		
		menuBarsQuery.menuItems["About CodePiece"].click()
		XCTAssertTrue(aboutWindow.exists)
		
		mainWindow.buttons[XCUIIdentifierCloseWindow].click()
		XCTAssertTrue(mainWindow.exists, "Expected main window will not colse because other modal window is appeared.")
		
		aboutWindow.buttons[XCUIIdentifierCloseWindow].click()
		XCTAssertFalse(aboutWindow.exists, "Expected modal window closed.")

		mainWindow.buttons[XCUIIdentifierCloseWindow].click()
		XCTAssertFalse(mainWindow.exists, "Expected main window will close because modal window is already finished.")
	}
	
	func testApplicationEnvironments() {
		
		let application = XCUIApplication()
		
		continueAfterFailure = true
		application.launch()
		
		XCTAssertFalse(application.launchArguments.contains("RUN_SCHEME"), "RUN スキームの引数は受け取らない様子")
		XCTAssertFalse(application.launchArguments.contains("TEST_SCHEME"), "アプリは TEST スキームの引数は受け取らない")
		XCTAssertFalse(application.launchArguments.contains("XCRUN"))
		
		XCTAssertNotEqual(application.launchEnvironment["ENV_SCHEME"], "RUN", "RUN スキームの環境変数は受け取らない様子")
		XCTAssertNotEqual(application.launchEnvironment["ENV_SCHEME"], "TEST", "アプリは TEST スキームの環境変数は受け取らない")
		XCTAssertNotEqual(application.launchEnvironment["XCENV"], "XCRUN")
		
		application.launchArguments.append("XCRUN")
		application.launchEnvironment["XCENV"] = "XCRUN"
		
		XCTAssertFalse(application.launchArguments.contains("RUN_SCHEME"), "RUN スキームの引数は受け取らない様子")
		XCTAssertFalse(application.launchArguments.contains("TEST_SCHEME"), "アプリは TEST スキームの引数は受け取らない")
		XCTAssertTrue(application.launchArguments.contains("XCRUN"))
		
		XCTAssertNotEqual(application.launchEnvironment["ENV_SCHEME"], "RUN", "RUN スキームの環境変数は受け取らない様子")
		XCTAssertNotEqual(application.launchEnvironment["ENV_SCHEME"], "TEST", "アプリは TEST スキームの環境変数は受け取らない")
		XCTAssertEqual(application.launchEnvironment["XCENV"], "XCRUN")
	}
	
	func testFindControls() {
		
		let app = XCUIApplication()
		
		continueAfterFailure = true
		app.launch()
		
		let mainWindow = app.windows["CodePiece"]
		
		let hashtagTextField = mainWindow.textFields["HashtagTextFieldIdentifier"]
		let unknownTextField = mainWindow.textFields["Unknown"]
		let codeLabel = mainWindow.staticTexts["Code"]
		let unknownLabel = mainWindow.staticTexts["Unknown"]

		XCTAssertTrue(hashtagTextField.exists)
		XCTAssertFalse(unknownTextField.exists)
		XCTAssertTrue(codeLabel.exists)
		XCTAssertFalse(unknownLabel.exists)
				
		let viewByIdentifier = mainWindow.textViews["CodeTextIdentifier"]
		let viewByAccessibilityDescription = mainWindow.textViews["Code Text Field"]
		let viewByAccessibilityHelp = mainWindow.textViews["Input text for post."]
		let viewByAccessibilityIdentifier = mainWindow.textViews["TextFieldForInputCode"]

		XCTAssertFalse(viewByIdentifier.exists, "Adopt Accessibility Description and Accessibility Identifier preferentially.")
		XCTAssertTrue(viewByAccessibilityDescription.exists, "Accessibility Identifier/Description is highest.")
		XCTAssertFalse(viewByAccessibilityHelp.exists, "Always not found.")
		XCTAssertTrue(viewByAccessibilityIdentifier.exists, "Accessibility Identifier/Description is highest priority.")
	}
	
	func testAutoEnabled() {
		
		let app = XCUIApplication()
		
		app.launch()
		
		let mainWindow = app.windows["CodePiece"]
		let menuBarsQuery = app.menuBars
		
		let codeTextView = mainWindow.textViews["TextFieldForInputCode"]
		let TweetTextField = mainWindow.textFields["TweetTextFieldIdentifier"]
		let hashtagTextField = mainWindow.textFields["HashtagTextFieldIdentifier"]
		let tweetButton = mainWindow.buttons["PostButtonIdentifier"]

		menuBarsQuery.menuItems["Clear Code"].click()
		menuBarsQuery.menuItems["Clear Tweet & Description"].click()
		menuBarsQuery.menuItems["Clear Hashtag"].click()
		
		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertFalse(tweetButton.enabled)

		// CodeTextView
		
		codeTextView.click()
		codeTextView.typeText("a")

		XCTAssertEqual(tweetButton.title, "Post Gist")
		XCTAssertFalse(tweetButton.enabled)
		
		codeTextView.typeKey(XCUIKeyboardKeyDelete, modifierFlags: .None)

		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertFalse(tweetButton.enabled)

		// HashtagTextField

		hashtagTextField.click()
		hashtagTextField.typeText("a")
		
		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertFalse(tweetButton.enabled)
		
		hashtagTextField.typeKey(XCUIKeyboardKeyDelete, modifierFlags: .None)
		
		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertFalse(tweetButton.enabled)
		
		// TweetTextField
		
		TweetTextField.click()
		TweetTextField.typeText("a")
		
		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertTrue(tweetButton.enabled)
		
		TweetTextField.typeKey(XCUIKeyboardKeyDelete, modifierFlags: .None)
		
		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertFalse(tweetButton.enabled)
	}
	
	func testTweetButton() {
		
		let app = XCUIApplication()
		
		app.launch()
		
		let mainWindow = app.windows["CodePiece"]
		let menuBarsQuery = app.menuBars
	
		let codeTextView = mainWindow.textViews["TextFieldForInputCode"]
		let TweetTextField = mainWindow.textFields["TweetTextFieldIdentifier"]
		let hashtagTextField = mainWindow.textFields["HashtagTextFieldIdentifier"]
		let tweetButton = mainWindow.buttons["PostButtonIdentifier"]
	
		menuBarsQuery.menuItems["Clear Code"].click()
		menuBarsQuery.menuItems["Clear Tweet & Description"].click()
		menuBarsQuery.menuItems["Clear Hashtag"].click()

		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertFalse(tweetButton.enabled)

		hashtagTextField.click()
		hashtagTextField.typeText("CodePiece")
		
		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertFalse(tweetButton.enabled)

		TweetTextField.click()
		TweetTextField.typeText("Test")

		XCTAssertEqual(tweetButton.title, "Tweet")
		XCTAssertTrue(tweetButton.enabled)
		
		codeTextView.click()
		codeTextView.typeText("print(\"hello\")\n")

		XCTAssertEqual(tweetButton.title, "Post Gist")
		XCTAssertTrue(tweetButton.enabled)
	}
	
    func testHashtag() {

		let app = XCUIApplication()
		
		app.launch()

		let mainWindow = app.windows["CodePiece"]
		let menuBarsQuery = app.menuBars

		menuBarsQuery.menuItems["Clear Hashtag"].click()

		let hashtagTextField = mainWindow.textFields["HashtagTextFieldIdentifier"]

		hashtagTextField.click()
		hashtagTextField.typeKey("a", modifierFlags: .Command)
		hashtagTextField.typeText("xcode")
		hashtagTextField.typeText("\r")
		
		XCTAssertEqual(hashtagTextField.value as? String, "#xcode", "Hashtag completion test.")
		
		menuBarsQuery.menuBarItems["Editor"].click()
		menuBarsQuery.menuItems["Clear Hashtag"].click()
		
		XCTAssertEqual(hashtagTextField.value as? String, "", "expected hashtag field is reset.")
    }
}
