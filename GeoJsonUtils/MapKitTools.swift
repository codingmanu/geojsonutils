//
//  MapKitTools.swift
//  SwiftCityJSONTest
//
//  Created by Manuel S. Gomez on 12/21/18.
//  Copyright © 2018 codingManu. All rights reserved.
//

import Foundation
import MapKit

extension MKPolygon {

    func containsPoint(_ point: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let mapPoint: MKMapPoint = MKMapPoint(point)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: mapPoint)

        if polygonRenderer.path.contains(polygonViewPoint) {
            return true
        }

        return false
    }
}

extension MKMapView {

    func squareAroundCoordinate(_ coordinate: CLLocationCoordinate2D, withScaleFactor scale: Double) -> MKMapRect {
        let currentMapSize = self.visibleMapRect.size
        let touchWidth = currentMapSize.width * scale
        let newSize = MKMapSize(width: touchWidth, height: touchWidth)

        let point = MKMapPoint(coordinate)
        let newX = point.x - ( touchWidth / 2 )
        let newY = point.y - ( touchWidth / 2 )

        let newPoint = MKMapPoint(x: newX, y: newY)

        return MKMapRect(origin: newPoint, size: newSize)
    }

    func loadFeatureCollection(_ featureCollection: FeatureCollection) {
        for feature in featureCollection.features {
            switch feature.geometryType {
            case .point:
                self.loadPointFeatureAsAnnotation(feature)
            case .lineString:
                self.loadLineStringFeatureAsOverlay(feature)
            case .polygon:
                self.loadPolygonFeatureAsOverlay(feature)
            case .multiPolygon:
                self.loadMultiPolygonFeatureAsOverlay(feature)
            default:
                return
            }
        }
    }

    func loadPointsAsAnnotations(_ points: [Point]) {
        for point in points {
            self.addAnnotation(point.asMKPointAnnotation())
        }
    }

    func loadPointFeatureAsAnnotation(_ feature: Feature) {
        if feature.geometryType == .point {
            if let point = feature.mkGeometry as? MKPointAnnotation {
                self.addAnnotation(point)
            }
        }
    }

    func loadLineStringFeatureAsOverlay(_ feature: Feature) {
        if feature.geometryType == .lineString {
            if let polyline = feature.mkGeometry as? MKPolyline {
                self.addOverlay(polyline)
            }
        }
    }

    func loadPolygonFeatureAsOverlay(_ feature: Feature) {
        if feature.geometryType == .polygon {
            if let polygon = feature.mkGeometry as? MKPolygon {
                self.addOverlay(polygon)
            }
        }
    }

    func loadMultiPolygonFeatureAsOverlay(_ feature: Feature){
        if feature.geometryType == .multiPolygon {
            if feature.multiMkGeometry != nil {
                for mkGeometry in feature.multiMkGeometry! {
                    if let polygon = mkGeometry as? MKPolygon {
                        self.addOverlay(polygon)
                    }
                }
            }
        }
    }
}
