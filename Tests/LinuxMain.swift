import XCTest

import GeoJsonUtilsTests

var tests = [XCTestCaseEntry]()
tests += GeoJsonUtilsUnitTests.allTests()
tests += MapKitToolsTests.allTests()
XCTMain(tests)
