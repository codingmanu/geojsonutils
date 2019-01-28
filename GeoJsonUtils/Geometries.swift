//
//  Geometries.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 12/23/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

// MARK: - Enums for type, error & coding keys
enum GeometryType: String, Decodable {

    case point = "Point"
    case lineString = "LineString"
    case polygon = "Polygon"
    case multiPoint = "MultiPoint"
    case multiLineString = "MultiLineString"
    case multiPolygon = "MultiPolygon"
}

enum GeometryError: Error {
    case invalidType
    case invalidGeometry
    case indalidId
}

enum GeometryCodingKeys: String, CodingKey {
    case type
    case coordinates
}

// MARK: - Models
class Point: Decodable {
    var type: GeometryType = .point
    var coordinates: [Double]

    init(_ coordinates: [Double]) {
        self.coordinates = coordinates
    }
}

class LineString: Decodable {
    var type: GeometryType = .lineString
    var coordinates: [[Double]]

    init(_ coordinates: [[Double]]) {
        self.coordinates = coordinates
    }
}

class Polygon: Decodable {
    var type: GeometryType = .polygon
    var coordinates: [[[Double]]]

    init(_ coordinates: [[[Double]]]) {
        self.coordinates = coordinates
    }
}

class MultiPolygon: Decodable {
    var type: GeometryType = .multiPolygon
    var coordinates: [[[[Double]]]]

    init(_ coordinates: [[[[Double]]]]) {
        self.coordinates = coordinates
    }
}

// MARK: - Extensions
extension Point {

    private func asCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        let lat = coordinates[1]
        let lon = coordinates[0]

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func asMKPointAnnotation() -> MKPointAnnotation {
        let anno = MKPointAnnotation()
        anno.coordinate = self.asCLLocationCoordinate2D()
        return anno
    }
}

extension LineString {

    private func getPoints() -> [Point] {
        let points = coordinates.map { (coordinate) -> Point in
            return Point(coordinate)
        }
        return points
    }

    func asMKPolyLine() -> MKPolyline {

        let coords = self.getPoints().compactMap({ (point) -> CLLocationCoordinate2D in
            return point.asMKPointAnnotation().coordinate
        })

        return MKPolyline(coordinates: coords, count: coords.count)
    }
}

extension Polygon {

    private func getOuterRing() -> LineString {
        return LineString(coordinates[0])
    }

    private func getInnerRings() -> [LineString] {
        var innerRings: [LineString] = []
        if coordinates.count > 1 {
            for ring in coordinates[1...] {
                innerRings.append(LineString(ring))
            }
        }
        return innerRings
    }

    func asMKPolygon() -> MKPolygon {
        var outerPolygonPoints = [CLLocationCoordinate2D]()

        let outerRing = self.getOuterRing()
        for point in UnsafeBufferPointer(start: outerRing.asMKPolyLine().points(),
                                         count: outerRing.asMKPolyLine().pointCount) {
                                            outerPolygonPoints.append(point.coordinate)
        }

        var innerPolygons = [MKPolygon]()

        let innerRings = self.getInnerRings()
        if innerRings.count > 0 {
            for innerRing in innerRings {
                var innerPolygonPoints = [CLLocationCoordinate2D]()
                for point in UnsafeBufferPointer(start: innerRing.asMKPolyLine().points(),
                                                 count: innerRing.asMKPolyLine().pointCount) {
                                                    innerPolygonPoints.append(point.coordinate)
                }

                innerPolygons.append(MKPolygon(coordinates: innerPolygonPoints, count: innerPolygonPoints.count))
            }
        }

        let mkPoly = MKPolygon(coordinates: outerPolygonPoints,
                               count: outerPolygonPoints.count,
                               interiorPolygons: innerPolygons)

        return mkPoly
    }
}

extension MultiPolygon {

    func getPolygons() -> [Polygon] {
        let polygons = coordinates.map { (coordinate) -> Polygon in
            return Polygon(coordinate)
        }
        return polygons
    }
}
