import Cocoa
import FlutterMacOS
import XCTest

final class RunnerTests: XCTestCase {
  func testRunnerTargetLoads() {
    XCTAssertNotNil(NSApplication.shared.delegate)
  }
}
