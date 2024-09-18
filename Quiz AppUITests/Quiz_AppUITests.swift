//
//  Quiz_AppUITests.swift
//  Quiz AppUITests
//
//  Created by Geovani Oneal on 8/12/24.
//

import XCTest

final class Quiz_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testNextGameButtonFunctionality() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the game list
        app.buttons["Start"].tap()

        // Test Random Game functionality
        app.buttons["Random Game"].tap()
        XCTAssertTrue(app.staticTexts.element(matching: .any, identifier: "QuestionText").exists, "Random game should have started")

        // Play the game and finish it
        for _ in 1...5 { // Assuming 5 questions per game
            app.buttons.firstMatch.tap() // Tap the first answer option
            app.buttons["Next Question"].tap()
        }

        // Verify "Next Game" button is present and tap it
        XCTAssertTrue(app.buttons["Next Game"].exists, "Next Game button should be visible")
        app.buttons["Next Game"].tap()

        // Verify that a new game has started
        XCTAssertTrue(app.staticTexts.element(matching: .any, identifier: "QuestionText").exists, "New game should have started")

        // Verify back button functionality
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.exists, "Back button should be visible")
        backButton.tap()

        // Verify we're back at the game index
        XCTAssertTrue(app.navigationBars["Quiz Games"].exists, "Should be back at the game index")

        // Test navigation to a specific game
        app.buttons.firstMatch.tap() // Tap the first game in the list
        XCTAssertTrue(app.staticTexts.element(matching: .any, identifier: "QuestionText").exists, "Specific game should have started")

        // Verify back button functionality again
        backButton.tap()
        XCTAssertTrue(app.navigationBars["Quiz Games"].exists, "Should be back at the game index after specific game")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
