//
//  GeoJsonUtilsAppTests.swift
//  GeoJsonUtilsAppTests
//
//  Created by Manuel S. Gomez on 1/28/19.
//  Copyright © 2019 codingManu. All rights reserved.
//

import XCTest
@testable import GeoJsonUtils
import MapKit

class GeoJsonUtilsAppTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // swiftlint:disable all
    func testPoint() {
        let data = TestResources.samplePoint.data(using: .utf8)
        let decoder = JSONDecoder()
        let decodedData = try? decoder.decode(GJPoint.self, from: data!)

        guard let point = decodedData else { return }

        XCTAssertEqual(point.coordinates[0], -73.97604935657381, accuracy: 0.0000000000001)
        XCTAssertEqual(point.coordinates[1], 40.631275905646774, accuracy: 0.0000000000001)
        XCTAssertEqual(point.coordinates.count, 2)

        let coordinate = CLLocationCoordinate2D(latitude: point.coordinates[1], longitude: point.coordinates[0])
        XCTAssertEqual(point.asMKPointAnnotation().coordinate.latitude, coordinate.latitude, accuracy: 0.0000000000001)
        XCTAssertEqual(point.asMKPointAnnotation().coordinate.longitude, coordinate.longitude, accuracy: 0.0000000000001)
    }

    func testLineString() {
        let data = TestResources.sampleLineString.data(using: .utf8)
        let decoder = JSONDecoder()
        let decodedData = try? decoder.decode(GJLineString.self, from: data!)

        guard let line = decodedData else { return }

        XCTAssertEqual(line.coordinates[0][0], -73.97604935657381, accuracy: 0.0000000000001)
        XCTAssertEqual(line.coordinates[0][1], 40.631275905646774, accuracy: 0.0000000000001)
        XCTAssertEqual(line.coordinates[1][0], -74.00236943480249, accuracy: 0.0000000000001)
        XCTAssertEqual(line.coordinates[1][1], 40.638957677813941, accuracy: 0.0000000000001)

        XCTAssertEqual(line.coordinates.count, 2)
        XCTAssertEqual(line.asMKPolyLine().pointCount, 2)

        let coordinate1 = CLLocationCoordinate2D(latitude: 40.631275905646774,
                                                 longitude: -73.97604935657381)
        XCTAssertEqual(coordinate1.latitude, line.asMKPolyLine().points()[0].coordinate.latitude, accuracy: 0.0000000000001)
        XCTAssertEqual(coordinate1.longitude, line.asMKPolyLine().points()[0].coordinate.longitude, accuracy: 0.0000000000001)

        let coordinate2 = CLLocationCoordinate2D(latitude: 40.638957677813941,
                                                 longitude: -74.00236943480249)
        XCTAssertEqual(coordinate2.latitude, line.asMKPolyLine().points()[1].coordinate.latitude, accuracy: 0.0000000000001)
        XCTAssertEqual(coordinate2.longitude, line.asMKPolyLine().points()[1].coordinate.longitude, accuracy: 0.0000000000001)
    }

    func testPolygon() {
        let data = TestResources.samplePolygon.data(using: .utf8)
        let decoder = JSONDecoder()
        let decodedData = try? decoder.decode(GJPolygon.self, from: data!)

        guard let polygon = decodedData else { return }

        let mkPoly = polygon.asMKPolygon()

        XCTAssertEqual(polygon.coordinates[0].count, 130)
        XCTAssertEqual(mkPoly.pointCount, 130)

        for (index, mkPoint) in UnsafeBufferPointer(start: mkPoly.points(), count: mkPoly.pointCount).enumerated() {
            let point = CLLocationCoordinate2D(latitude: polygon.coordinates[0][index][1], longitude: polygon.coordinates[0][index][0])
            XCTAssertEqual(point.latitude, mkPoint.coordinate.latitude, accuracy: 0.0000000000001)
            XCTAssertEqual(point.longitude, mkPoint.coordinate.longitude, accuracy: 0.0000000000001)
        }
    }
}
// swiftlint:enable all
