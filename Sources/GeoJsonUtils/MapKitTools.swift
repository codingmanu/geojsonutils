//
//  MapKitTools.swift
//  GeoJsonUtils
//
//  Created by Manuel S. Gomez on 12/21/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

public extension CLLocationCoordinate2D {

    /// Calculates the distance between two coordinates.
    /// ATTENTION: Does not work across the antemeridian.
    ///
    /// - Parameter coordinate: _CLLocationCoordinate2D_, Coordinate to calculate distance to.
    /// - Returns: _Double_, Distance in degrees.
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let horizontalDistance = self.longitude - coordinate.longitude
        let verticalDistance = self.latitude - coordinate.latitude
        return sqrt((horizontalDistance * horizontalDistance)+(verticalDistance * verticalDistance))
    }
}

public extension MKPolyline {

    /// Returns the length of the polyline
    ///
    /// - Returns: _Double_, returns the length of the polyline.
    func length() -> Double {
        // If the line has less than two points, distance is zero, so bail out.
        if self.pointCount < 2 {
            return 0.0
        }

        var length = 0.0
        var lastPoint = self.points()[0]

        // Adds the distance from the previous point to the total length.
        for point in UnsafeBufferPointer(start: self.points(), count: self.pointCount) {
            let coordinate = point.coordinate
            let lastPointCoordinate = lastPoint.coordinate
            let distance = lastPointCoordinate.distance(to: coordinate)
            length += distance
            lastPoint = point
        }

        return length
    }
}

public extension MKPolygon {

    /// Checks if a given coordinate is inside the polygon.
    ///
    /// - Parameter coordinate: _CLLocationCoordinate2D_, the coordinate to check.
    /// - Returns: _Bool_, returns `true` if the coordinate is inside the polygon's path.
    func containsCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let mapPoint: MKMapPoint = MKMapPoint(coordinate)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: mapPoint)

        return polygonRenderer.path.contains(polygonViewPoint)
    }
}

public extension MKMapView {

    /// Adds a square buffer around a coordinate.
    ///
    /// - Parameters:
    ///   - coordinate: _CLLocationCoordinate2D_, coordinate to create the buffer around.
    ///   - scale: Optional Scale that adjusts the size of the rectangle compared to the MKMapView width. Default = 1 to take the whole Map view width.
    /// - Returns: _MKMapRect_, the rectangle buffer around the given coordinate.
    func squareAroundCoordinate(_ coordinate: CLLocationCoordinate2D, withScaleFactor scale: Double = 1) -> MKMapRect {
        let currentMapSize = self.visibleMapRect.size
        let rectangleSide = currentMapSize.width * scale
        let newSize = MKMapSize(width: rectangleSide, height: rectangleSide)

        let point = MKMapPoint(coordinate)
        let newX = point.x - ( rectangleSide / 2 )
        let newY = point.y - ( rectangleSide / 2 )

        let newPoint = MKMapPoint(x: newX, y: newY)

        return MKMapRect(origin: newPoint, size: newSize)
    }

    /// Loads a GJFeatureCollection into the MKMapview.
    ///
    /// - Parameter featureCollection: The collection to be loaded into the map.
    func loadGJFeatureCollection(_ featureCollection: GJFeatureCollection) {
        for feature in featureCollection.features {
            switch feature.geometryType {
            case .point:
                self.loadGJPointFeatureAsAnnotation(feature)
            case .multiPoint:
                self.loadGJMultiPointFeatureAsAnnotations(feature)
            case .lineString, .multiLineString, .polygon, .multiPolygon:
                self.loadGJFeatureAsOverlay(feature)
            }
        }
    }

    /// Loads array of GJPoints into the map as MKPointAnnotation.
    ///
    /// - Parameter points: GJPoint array to be loaded into the map.
    func loadGJPointsAsAnnotations(_ points: [GJPoint]) {
        DispatchQueue.main.async { [unowned self] in
            for point in points {
                self.addAnnotation(point.asMKPointAnnotation())
            }
        }
    }

    /// Loads a `GJPointFeature` into the map as a `MKPointAnnotation`.
    ///
    /// - Parameter feature: the feature object to be loaded into the map.
    func loadGJPointFeatureAsAnnotation(_ feature: GJFeature) {
        DispatchQueue.main.async { [unowned self] in
            if feature.geometryType == .point {
                if let point = feature.mkGeometry as? MKPointAnnotation {
                    self.addAnnotation(point)
                }
            }
        }
    }

    /// Loads a `GJMultiPointFeature` into the map as multiple `MKPointAnnotation`.
    ///
    /// - Parameter feature: the feature object to be loaded into the map.
    func loadGJMultiPointFeatureAsAnnotations(_ feature: GJFeature) {
        if feature.geometryType == .multiPoint {
            DispatchQueue.main.async { [unowned self] in
                if let points = feature.multiMkGeometry as? [MKPointAnnotation] {
                    for point in points {
                        self.addAnnotation(point)
                    }
                }
            }
        }
    }

    /// Loads a `GJFeature` into the map as a `MKOverlay`.
    ///
    /// - Parameter feature: the feature object to be loaded into the map. Works for features containing
    ///     `GJLineString`, `GJMultiLineString`,  `GJPolygon` and `GJMultiPolygon`.
    func loadGJFeatureAsOverlay(_ feature: GJFeature) {
        DispatchQueue.main.async { [unowned self] in
            switch feature.geometryType {
            case .lineString:
                if let polyline = feature.mkGeometry as? MKPolyline {
                    self.addOverlay(polyline)
                }
            case .multiLineString:
                if let multiLine = feature.multiMkGeometry as? [MKPolyline] {
                    for line in multiLine {
                        self.addOverlay(line)
                    }
                }
            case .polygon:
                if let polygon = feature.mkGeometry as? MKPolygon {
                    self.addOverlay(polygon)
                }
            case .multiPolygon:
                if feature.multiMkGeometry != nil {
                    for mkGeometry in feature.multiMkGeometry! {
                        if let polygon = mkGeometry as? MKPolygon {
                            self.addOverlay(polygon)
                        }
                    }
                }
            default:
                break
            }
        }
    }
}
