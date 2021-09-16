//
//  Geometries.swift
//  GeoJsonUtils
//
//  Created by Manuel S. Gomez on 12/23/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

// MARK: - Enums for type, error & coding keys
public enum GJGeometryType: String, Decodable {

    case point = "Point"
    case lineString = "LineString"
    case polygon = "Polygon"
    case multiPoint = "MultiPoint"
    case multiLineString = "MultiLineString"
    case multiPolygon = "MultiPolygon"
}

public enum GJGeometryError: Error {
    case invalidType
    case invalidGeometry
    case indalidId
}

public enum GJGeometryCodingKeys: String, CodingKey {
    case type
    case coordinates
}

// MARK: - Models
public class GJPoint: Decodable {
    public var type: GJGeometryType = .point
    public var coordinates: [Double]

    init(_ coordinates: [Double]) {
        self.coordinates = coordinates
    }
}

public class GJMultiPoint: Decodable {
    public var type: GJGeometryType = .multiPoint
    public var coordinates: [[Double]]

    init(_ coordinates: [[Double]]) {
        self.coordinates = coordinates
    }

    init(_ coordinates: [GJPoint]) {
        self.coordinates = coordinates.map({ (point) -> [Double] in
            return point.coordinates
        })
    }
}

public class GJLineString: Decodable {
    public var type: GJGeometryType = .lineString
    public var coordinates: [[Double]]

    init(_ coordinates: [[Double]]) {
        self.coordinates = coordinates
    }

    init(_ coordinates: [GJPoint]) {
        self.coordinates = coordinates.map({ (point) -> [Double] in
            return point.coordinates
        })
    }
}

public class GJMultiLineString: Decodable {
    public var type: GJGeometryType = .multiLineString
    public var coordinates: [[[Double]]]

    init(_ coordinates: [[[Double]]]) {
        self.coordinates = coordinates
    }

    init(_ coordinates: [GJLineString]) {
        self.coordinates = coordinates.map({ (lineString) -> [[Double]] in
            return lineString.coordinates
        })
    }
}

public class GJPolygon: Decodable {
    public var type: GJGeometryType = .polygon
    public var coordinates: [[[Double]]]

    init(_ coordinates: [[[Double]]]) {
        self.coordinates = coordinates
    }

    init(_ coordinates: [GJLineString]) {
        self.coordinates = coordinates.map({ (line) -> [[Double]] in
            return line.coordinates
        })
    }
}

public class GJMultiPolygon: Decodable {
    public var type: GJGeometryType = .multiPolygon
    public var coordinates: [[[[Double]]]]

    init(_ coordinates: [[[[Double]]]]) {
        self.coordinates = coordinates
    }

    init(_ coordinates: [GJPolygon]) {
        self.coordinates = coordinates.map({ (polygon) -> [[[Double]]] in
            return polygon.coordinates
        })
    }
}

// MARK: - Conversion Extensions
public extension GJPoint {

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

public extension GJMultiPoint {

    private func asCLLocationCoordinate2DArray() -> [CLLocationCoordinate2D] {

        return coordinates.map { (coordinate) -> CLLocationCoordinate2D in
            let lat = coordinate[1]
            let lon = coordinate[0]

            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    func asMKPointAnnotationArray() -> [MKPointAnnotation] {

        let locations = self.asCLLocationCoordinate2DArray()

        return locations.map { (location) -> MKPointAnnotation in
            let anno = MKPointAnnotation()
            anno.coordinate = location
            return anno
        }
    }
}

public extension GJLineString {

    fileprivate func getPoints() -> [GJPoint] {
        let points = coordinates.map { (coordinate) -> GJPoint in
            return GJPoint(coordinate)
        }
        return points
    }

    func asMKPolyLine() -> MKPolyline {

        let coordinates = self.getPoints().map { (point) -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: point.coordinates[1], longitude: point.coordinates[0])
        }

        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }

    func isClosed() -> Bool {
        return coordinates[0] == coordinates[coordinates.count-1]
    }
}

public extension GJMultiLineString {

    fileprivate func getLines() -> [GJLineString] {
        let lines = coordinates.map { (line) -> GJLineString in
            return GJLineString(line)
        }
        return lines
    }

    func asMKPolyLineArray() -> [MKPolyline] {

        var lines = [MKPolyline]()

        self.getLines().forEach { (line) in

            var coords = [CLLocationCoordinate2D]()

            let points = line.getPoints().compactMap({ (point) -> CLLocationCoordinate2D in
                return point.asMKPointAnnotation().coordinate
            })
            coords.append(contentsOf: points)

            lines.append(MKPolyline(coordinates: coords, count: coords.count))
        }

        return lines
    }
}

public extension GJPolygon {

    private func getOuterRing() -> GJLineString {
        return GJLineString(coordinates[0])
    }

    private func getInnerRings() -> [GJLineString] {
        var innerRings: [GJLineString] = []
        if coordinates.count > 1 {
            for ring in coordinates[1...] {
                innerRings.append(GJLineString(ring))
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

public extension GJMultiPolygon {

    func getPolygons() -> [GJPolygon] {
        let polygons = coordinates.map { (coordinate) -> GJPolygon in
            return GJPolygon(coordinate)
        }
        return polygons
    }
}
