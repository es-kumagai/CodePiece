//
//  AboutWindowUITests.m
//  AboutWindowUITests
//
//  Created by Tomohiro Kumagai on H27/11/03.
//  Copyright © 平成27年 EasyStyle G.K. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AboutWindowUITests : XCTestCase

@end

@implementation AboutWindowUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
	
	XCUIElementQuery *menuBarsQuery = [[XCUIApplication alloc] init].menuBars;

	[XCUIElement performWithKeyModifiers:XCUIKeyModifierAlphaShift block:^{
		[menuBarsQuery.menuItems[@"About CodePiece"] click];
	}];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDisplaying {

	XCUIApplication* app = [[XCUIApplication alloc] init];
	XCUIElement* window = [app.windows objectForKeyedSubscript:@""];
	
	XCUIElement* titleLabel = [app.staticTexts objectForKeyedSubscript:@"CodePiece"];

	XCTAssertTrue(window.exists);
	XCTAssertTrue(titleLabel.exists);
}

- (void)testCannotResizing {
	
	XCUIApplication* app = [[XCUIApplication alloc] init];
	XCUIElement* button = [app.buttons objectForKeyedSubscript:XCUIIdentifierZoomWindow];
	
	XCTAssertFalse(button.enabled, "Button for resize is expected to always disabled.");
}

@end
