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
}

enum GeometryCodingKeys: String, CodingKey {
    case type
    case coordinates
}

// MARK: - Models
struct Point: Decodable {
    var type: GeometryType = .point
    var coordinates: [Double]

    init(_ coordinates: [Double]) {
        self.coordinates = coordinates
    }
}

struct LineString: Decodable {
    var type: GeometryType = .lineString
    var coordinates: [[Double]]

    init(_ coordinates: [[Double]]) {
        self.coordinates = coordinates
    }
}

struct Polygon: Decodable {
    var type: GeometryType = .polygon
    var coordinates: [[[Double]]]

    init(_ coordinates: [[[Double]]]) {
        self.coordinates = coordinates
    }
}

struct MultiPolygon: Decodable {
    var type: GeometryType = .multiPolygon
    var coordinates: [[[[Double]]]]

    init(_ coordinates: [[[[Double]]]]) {
        self.coordinates = coordinates
    }
}

// MARK: - Extensions
extension Point {
    func asCLLocationCoordinate2D() -> CLLocationCoordinate2D {
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

    func getPoints() -> [Point] {
        let points = coordinates.map { (coordinate) -> Point in
            return Point(coordinate)
        }
        return points
    }

    func asMKPolyLine() -> MKPolyline {

        let coords = self.getPoints().map({ (point) -> CLLocationCoordinate2D in
            return point.asCLLocationCoordinate2D()
        })

        return MKPolyline(coordinates: coords, count: coords.count)
    }
}

extension Polygon {

    func getOuterRing() -> LineString {
        return LineString(coordinates[0])
    }

    func getInnerRings() -> [LineString] {
        var innerRings: [LineString] = []
        if coordinates.count > 1 {
            for ring in coordinates[1...] {
                innerRings.append(LineString(ring))
            }
        }
        return innerRings
    }

    func asMKPolygon() -> MKPolygon {
        var outerPolygonPoints = [Point]()

        let outerRing = self.getOuterRing()
        outerRing.coordinates.forEach { (point) in
            outerPolygonPoints.append(Point(point))
        }

        let outerCoordinates = outerPolygonPoints.map { (point) -> CLLocationCoordinate2D in
            return point.asCLLocationCoordinate2D()
        }

        var innerPolygons = [MKPolygon]()

        let innerRings = self.getInnerRings()
        if innerRings.count > 0 {
            for innerRing in innerRings {
                var innerPolygonPoints = [Point]()
                innerRing.getPoints().forEach({ (point) in
                    innerPolygonPoints.append(point)
                })
                let innerCoordinates = innerPolygonPoints.map { (point) -> CLLocationCoordinate2D in
                    return point.asCLLocationCoordinate2D()
                }
                innerPolygons.append(MKPolygon(coordinates: innerCoordinates, count: innerCoordinates.count))
            }
        }

        let mkPoly = MKPolygon(coordinates: outerCoordinates,
                               count: outerCoordinates.count,
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
