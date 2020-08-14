import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GeoJsonUtilsUnitTests.allCases),
        testCase(MapKitToolsTests.allCases),
    ]
}
#endif
