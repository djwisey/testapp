import Flutter
import UIKit
import XCTest

final class RunnerTests: XCTestCase {
  func testRunnerTargetLoads() {
    XCTAssertNotNil(UIApplication.shared.delegate)
  }
}
