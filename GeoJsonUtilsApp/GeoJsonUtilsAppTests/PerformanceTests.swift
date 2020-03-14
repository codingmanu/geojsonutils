//
//  PerformanceTests.swift
//  GeoJsonUtilsAppTests
//
//  Created by Manuel S. Gomez on 3/13/20.
//  Copyright © 2020 codingManu. All rights reserved.
//

import XCTest
@testable import GeoJsonUtilsApp
import MapKit

class PerformanceTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // swiftlint:disable all
    func testReadingFilePerformance() {

        self.measure {
            guard let bundlefile = Bundle.main.url(forResource: "nyc_neighborhoods", withExtension: "geojson") else {
                XCTFail("Test file doesn't exist")
                return
            }
            XCTAssertNotNil(try? Data(contentsOf: bundlefile))
        }
    }

    func testDecodingFilePerformance() {

        guard let bundlefile = Bundle.main.url(forResource: "nyc_neighborhoods", withExtension: "geojson") else {
            XCTFail("Test file doesn't exist")
            return
        }

        let data = try? Data(contentsOf: bundlefile)

        self.measure {
            let decoder = JSONDecoder()
            XCTAssertNotNil(try? decoder.decode(GJFeatureCollection.self, from: data!))
        }
    }
}
// swiftlint:enable all
