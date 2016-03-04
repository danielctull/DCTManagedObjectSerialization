
import XCTest
import CoreData
import Deserializer
import Tweets

class PerformanceTest: XCTestCase {
    
    func testTweets() {
		measureBlock() {
			let expectation = self.expectationWithDescription("Tweets")
			Tweets.importTweets { tweets in
				XCTAssert(tweets.count == 575)
				expectation.fulfill()
			}
			self.waitForExpectationsWithTimeout(30) { error in
				XCTAssertNil(error)
			}
		}
	}
}
