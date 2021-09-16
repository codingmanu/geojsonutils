//
//  MapKitToolsTests.swift
//  GeoJsonUtilsAppTests
//
//  Created by Manuel Gomez on 9/6/19.
//  Copyright © 2019 codingManu. All rights reserved.
//

import XCTest
@testable import GeoJsonUtils
import MapKit

class MapKitToolsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGJLineStringIsClosed() {
        let openLine = GJLineString([[0.0, 0.0], [0.0, 1.0], [1.0, 1.0], [1.0, 0.0]])
        XCTAssertFalse(openLine.isClosed())

        let closedLine = GJLineString([[0.0, 0.0], [0.0, 1.0], [1.0, 1.0], [1.0, 0.0], [0.0, 0.0]])
        XCTAssertTrue(closedLine.isClosed())
    }

    func testCLLocationCoordinate2DDistance() {
        let firstCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let secondCoordinate = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
        let distance = firstCoordinate.distance(to: secondCoordinate)
        XCTAssertEqual(distance, sqrt(2), accuracy: 0.0000000000001)
    }

    func testMKPolylineLength() {
        let badLine = GJLineString([[0.0, 0.0]])
        XCTAssertTrue(badLine.asMKPolyLine().length() == 0.0)

        let lineString = GJLineString([[0.0, 0.0], [0.0, 1.0], [1.0, 1.0], [1.0, 0.0]])
        let polyline = lineString.asMKPolyLine()
        let length = polyline.length()
        XCTAssertEqual(length, 3.0, accuracy: 0.0000000000001)
    }

    func testPolygonContainsCoordinate() {
        let polygon = GJPolygon([[[0.0, 0.0], [0.0, 1.0], [1.0, 1.0], [1.0, 0.0], [0.0, 0.0]]])
        let mkPolygon = polygon.asMKPolygon()
        let insidePoint = CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5)
        XCTAssertTrue(mkPolygon.containsCoordinate(insidePoint))

        let outsidePoint = CLLocationCoordinate2D(latitude: 2.5, longitude: 2.5)
        XCTAssertFalse(mkPolygon.containsCoordinate(outsidePoint))
    }

}
